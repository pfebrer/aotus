!> This module provides some convenient functions to act on Lua tables.
module aot_table_module
  use flu_binding
  use aot_kinds_module, only: double_k, single_k, long_k
  use aot_top_module, only: aot_top_get_val
  use aot_table_ops_module, only: aot_table_open, aot_table_close, &
    &                             aot_table_length, aot_table_first, &
    &                             aot_table_top, aot_table_push

  ! The following module enables an interface for quadruple precision numbers,
  ! if the compiler supports them. However, you should be aware, that this is
  ! merely a convenience interface, as the values provided by Lua are only
  ! double precision.
  use aot_quadruple_table_module

  implicit none

  private

  public :: aot_table_top, aot_table_length, aot_table_first, aot_table_push
  public :: aot_table_open, aot_table_close, aot_table_get_val
  public :: aot_table_from_1Darray
  public :: aot_table_set_val, aot_table_set_top
  public :: aot_get_val

  !> Get a value from a table.
  !!
  !! First the given key is looked up, if this fails, the value
  !! at the given position is looked up, and if this also fails,
  !! the default value is returned.
  !! Positional addressing is only valid, as long,
  !! as no value was provided by an explicit key
  !! in the list before the entry in question.
  interface aot_table_get_val
    module procedure get_table_real
    module procedure get_table_double
    module procedure get_table_integer
    module procedure get_table_long
    module procedure get_table_string
    module procedure get_table_logical
  end interface

  !> Set a value in a table.
  !!
  !! The given value will be put at the entry named by key into the table
  !! provided in thandle.
  !! Alternatively you can also put the value by position into the table by
  !! providing the pos argument.
  !! If both, pos and key are provided, the key will be used.
  !! Though, both of them are optional, at least one of them has to be provided.
  interface aot_table_set_val
    module procedure set_table_real
    module procedure set_table_double
    module procedure set_table_integer
    module procedure set_table_long
  end interface

  !> Get a value from a table.
  !!
  !! First the given key is looked up, if this fails, the value
  !! at the given position is looked up, and if this also fails,
  !! the default value is returned.
  !! Positional addressing is only valid, as long,
  !! as no value was provided by an explicit key
  !! in the list before the entry in question.
  !!
  !! The interface to access table values looks like:
  !! `call aot_get_val(val, errCode, L, thandle, key, pos, default)`.
  !! Position pos and key are both optional, but one of them has to be provided.
  !! If both are provided the key takes precedence over the pos, and the pos
  !! will only be tried if the access to the key fails.
  !! See for example get_table_real() for a more detailed
  !! description of the parameters.
  !!
  !! Note that positional addressing only works intuitively as long as there
  !! have been no entries specified by keys in the table.
  !! This kind of resembles the behavior of Fortran interfaces with named or
  !! unnamed arguments, as soon as you provide a name, all following arguments
  !! have to be given by key also.
  !! Just stick to this rule for the Lua tables as well to avoid too much
  !! headache.
  !!
  !! The reason for this is, that positional addressing in Lua refers only to
  !! the unnamed entries of the tables.
  interface aot_get_val
    module procedure get_table_real
    module procedure get_table_double
    module procedure get_table_integer
    module procedure get_table_long
    module procedure get_table_string
    module procedure get_table_logical
  end interface

  !> This interface enables the simple creation of uniform one dimensional
  !! arrays as tables in the Lua context.
  !!
  !! It takes an one dimensional array of values and returns a thandle to
  !! identify the newly generated table.
  interface aot_table_from_1Darray
    module procedure create_1Darray_real
    module procedure create_1Darray_double
  end interface

contains

  !> Retrieve a single precision real value from a table.
  subroutine get_table_real(val, ErrCode, L, thandle, key, pos, default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    real(kind=single_k), intent(out) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    real(kind=single_k), intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_real


  !> Retrieve a double precision real value from a table.
  subroutine get_table_double(val, ErrCode, L, thandle, key, pos, &
    &                         default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    real(kind=double_k), intent(out) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    real(kind=double_k), intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_double


  !> Retrieve a default integer value from a table.
  subroutine get_table_integer(val, ErrCode, L, thandle, key, pos, &
    &                          default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    integer, intent(out) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode


    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    integer, intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_integer


  !> Retrieve a long integer value from a table.
  subroutine get_table_long(val, ErrCode, L, thandle, key, pos, default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    integer(kind=long_k), intent(out) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    integer(kind=long_k), intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_long


  !> Retrieve a logical value from a table.
  subroutine get_table_logical(val, ErrCode, L, thandle, key, pos, &
    &                          default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    logical, intent(out) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    logical, intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_logical


  !> Retrieve a string from a table.
  subroutine get_table_string(val, ErrCode, L, thandle, key, pos, &
    &                         default)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    character(len=*) :: val

    !> Error code to indicate what kind of problem might have occured.
    integer, intent(out) :: ErrCode

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    !> Some default value, that should be used, if the variable is not set in
    !! the Lua script.
    character(len=*), intent(in), optional :: default

    call aot_table_push(L=L, thandle=thandle, &
      &                   key=key, pos=pos)
    call aot_top_get_val(val, ErrCode, L, default)

  end subroutine get_table_string


  !===========================================================================!


  !> Put the top of the stack into a table.
  subroutine aot_table_set_top(L, thandle, key, pos)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    integer :: indpos

    ! First store the current top of the stack for later reference, to
    ! move the desired position infront of it.
    indpos = flu_gettop(L)

    ! Only put the top into the given table, if it is a valid reference,
    ! and the top is not the table itself.
    if ( (thandle > 0) .and. (thandle < indpos) ) then

      if (present(key)) then
        ! There is a key, given, use it to put the value into the table.
        call flu_setField(L, thandle, trim(key))
      else
        ! No key given, try to put the value by position
        if (present(pos)) then
          ! First put the index, where to write the value into the table, on the
          ! stack.
          call flu_pushInteger(L, pos)
          ! Now move this position infront of the actual argument, which was
          ! at the top previously.
          call flu_insert(L, indpos)
          ! Use the two entries from the stack to put the value at the given
          ! position into the table.
          call flu_setTable(L, thandle)
        end if
      end if

    end if

  end subroutine aot_table_set_top


  !> Put a single precision real value into a table.
  subroutine set_table_real(val, L, thandle, key, pos)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    real(kind=single_k), intent(in) :: val

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    if (thandle > 0) then
      if (present(key)) then
        ! If there is a key, use that.
        ! First put the value on the top of the stack
        call flu_pushNumber(L, val)
        ! Now put it into the table
        call flu_setField(L, thandle, trim(key))
      else
        ! No key given, try to put the value by position
        if (present(pos)) then
          ! First put the index, where to write the value into the table, on the
          ! stack.
          call flu_pushInteger(L, pos)
          ! Now put the actual value on the top of the stack.
          call flu_pushNumber(L, val)
          ! Get the two entries from the stack into the table.
          call flu_setTable(L, thandle)
        end if
      end if
    end if

  end subroutine set_table_real


  !> Put a double precision real value into a table.
  subroutine set_table_double(val, L, thandle, key, pos)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    real(kind=double_k), intent(in) :: val

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    if (thandle > 0) then
      if (present(key)) then
        ! If there is a key, use that.
        ! First put the value on the top of the stack
        call flu_pushNumber(L, val)
        ! Now put it into the table
        call flu_setField(L, thandle, trim(key))
      else
        ! No key given, try to put the value by position
        if (present(pos)) then
          ! First put the index, where to write the value into the table, on the
          ! stack.
          call flu_pushInteger(L, pos)
          ! Now put the actual value on the top of the stack.
          call flu_pushNumber(L, val)
          ! Get the two entries from the stack into the table.
          call flu_setTable(L, thandle)
        end if
      end if
    end if

  end subroutine set_table_double


  !> Put a default integer value into a table.
  subroutine set_table_integer(val, L, thandle, key, pos)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    integer, intent(in) :: val

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    if (thandle > 0) then
      if (present(key)) then
        ! If there is a key, use that.
        ! First put the value on the top of the stack
        call flu_pushInteger(L, val)
        ! Now put it into the table
        call flu_setField(L, thandle, trim(key))
      else
        ! No key given, try to put the value by position
        if (present(pos)) then
          ! First put the index, where to write the value into the table, on the
          ! stack.
          call flu_pushInteger(L, pos)
          ! Now put the actual value on the top of the stack.
          call flu_pushInteger(L, val)
          ! Get the two entries from the stack into the table.
          call flu_setTable(L, thandle)
        end if
      end if
    end if

  end subroutine set_table_integer


  !> Put a long integer value into a table.
  subroutine set_table_long(val, L, thandle, key, pos)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to the table to look the value up in.
    integer, intent(in) :: thandle

    !> Value of the table entry if it exists.
    integer(kind=long_k), intent(in) :: val

    !> Name of the entry to look for.
    !!
    !! Key and pos are both optional, however at least one of them has to be
    !! supplied.
    !! The key takes precedence over the pos if both are given.
    character(len=*), intent(in), optional :: key

    !> Position of the entry to look for in the table.
    !!
    !! It allows the access to unnamed arrays in the Lua tables.
    integer, intent(in), optional :: pos

    if (thandle > 0) then
      if (present(key)) then
        ! If there is a key, use that.
        ! First put the value on the top of the stack
        call flu_pushInteger(L, int(val))
        ! Now put it into the table
        call flu_setField(L, thandle, trim(key))
      else
        ! No key given, try to put the value by position
        if (present(pos)) then
          ! First put the index, where to write the value into the table, on the
          ! stack.
          call flu_pushInteger(L, pos)
          ! Now put the actual value on the top of the stack.
          call flu_pushInteger(L, int(val))
          ! Get the two entries from the stack into the table.
          call flu_setTable(L, thandle)
        end if
      end if
    end if

  end subroutine set_table_long


  !> This subroutine takes a one dimensional array, and puts it as a table
  !! into the Lua context.
  !!
  !! The returned thandle provides the index to access this newly created
  !! table.
  subroutine create_1Darray_real(L, thandle, val)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to access the newly created table.
    integer, intent(out) :: thandle

    !> Values to put into the new table.
    real(kind=single_k), intent(in) :: val(:)

    integer :: tab
    integer :: nvals
    integer :: i

    nVals = size(val)
    call flu_createtable(L, nVals, 0)
    thandle = flu_gettop(L)
    tab = thandle

    do i=1,nVals
      call flu_pushInteger(L, i)
      call flu_pushNumber(L, val(i))
      call flu_settable(L, tab)
    end do

  end subroutine create_1Darray_real


  !> This subroutine takes a one dimensional array, and puts it as a table
  !! into the Lua context.
  !!
  !! The returned thandle provides the index to access this newly created
  !! table.
  subroutine create_1Darray_double(L, thandle, val)
    type(flu_State) :: L !< Handle to the Lua script.

    !> Handle to access the newly created table.
    integer, intent(out) :: thandle

    !> Values to put into the new table.
    real(kind=double_k), intent(in) :: val(:)

    integer :: tab
    integer :: nvals
    integer :: i

    nVals = size(val)
    call flu_createtable(L, nVals, 0)
    thandle = flu_gettop(L)
    tab = thandle

    do i=1,nVals
      call flu_pushInteger(L, i)
      call flu_pushNumber(L, val(i))
      call flu_settable(L, tab)
    end do

  end subroutine create_1Darray_double

end module aot_table_module
