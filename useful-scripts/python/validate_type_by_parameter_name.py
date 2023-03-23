# Validate type based on the signature and the parameter name. Based on:
# https://stackoverflow.com/a/58451182/7032856
# https://stackoverflow.com/a/29831586/7032856
# https://www.geeksforgeeks.org/python-get-function-signature/ 

from inspect import signature
from pydoc import locate
from typing import Any, Callable


def validate_type(object: Any, checked_type: type) -> None:
    if not isinstance(object, checked_type):
        raise TypeError(
            f"The value {object} is of type {type(object)}, not is of type {checked_type}.")


def validate_type_by_parameter_name(func: Callable, object: Any, parameter_name: str) -> None:
    parameters = signature(func).parameters
    parameter = parameters[parameter_name].annotation.__name__
    parameter_type = locate(parameter)
    validate_type(object, parameter_type)


def any_func(typed: str):
    validate_type_by_parameter_name(any_func, typed, f'{typed=}'.split('=')[0])
    # ... rest


if __name__ == '__main__':
    foo = dict()
    my_str = "bar"
    any_func(my_str) # no error
    any_func(foo)  # TypeError: The value {} is of type <class 'dict'>, not is of type <class 'str'>.
