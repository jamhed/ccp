# Python Typing Best Practices

**Source:** https://typing.python.org/en/latest/reference/best_practices.html
**Fetched:** 2025-11-23

## Type Aliases
Use `TypeAlias` annotation explicitly: `_IntList: TypeAlias = list[int]`. Don't annotate non-type assignments with `TypeAlias`.

## Using `Any` vs `object`
Reserve `Any` for situations where "a type cannot be expressed appropriately with the current type system." Prefer `object` when a function accepts any value (e.g., for `str()` conversion) or when callback return values are ignored.

## Function Signatures

**Arguments:** Favor abstract types and protocols (`Iterable`, `Mapping`, `Sequence`) over concrete types. Use `object` for parameters accepting any value, not `Any`.

**Return Types:** Prefer concrete types (`list`, `dict`) for implementations. Abstract base classes require case-by-case evaluation. Avoid union return types that necessitate `isinstance()` checks; use `Any` or `X | Any` if needed.

## Union and Optional Syntax
Use shorthand syntax exclusively: `str | int` instead of `Union[str, int]`, and `str | None` rather than `Optional[str]`. Position `None` as the final union element.

## Type Preferences
- Use `float` rather than `int | float`
- Use `None` instead of `Literal[None]`
- Employ built-in generics: `list[str]`, `type[MyClass]` rather than importing `List` and `Type` from `typing`
- Import from `collections.abc` (e.g., `Iterable`) instead of `typing`

## Core Philosophy
These recommendations are "constantly evolving," reflecting the maturation of Python's type system and community experience.

## Additional Resources

- [Python 3.14 Official Typing Documentation](https://docs.python.org/3/library/typing.html)
- [TypedDict Specification](https://typing.python.org/en/latest/spec/typeddict.html)
- [PEP 589 (TypedDict)](https://peps.python.org/pep-0589/)
