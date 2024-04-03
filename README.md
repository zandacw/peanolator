# Peano Arithmetic and Arithmetic Expression Parser in OCaml

## Introduction

This project is a dive into the world of Peano arithmetic and monadic parser combinators in OCaml. Peano arithmetic is a system of arithmetic based on natural numbers, using only a basic set of axioms. The goal of this project was to implement a Peano arithmetic library and an arithmetic expression parser using OCaml, providing a hands-on learning experience with these concepts.

## Peano Arithmetic Library

The Peano arithmetic library included in this project performs arithmetic operations using Peano numbers instead of the built-in arithmetic operations in OCaml. Peano numbers are a way to represent natural numbers using only a successor function and zero, without relying on the standard numerical operators.

## Arithmetic Expression Parser

Additionally, an arithmetic expression parser was implemented using monadic parser combinators in OCaml. Instead of using a monadic parser combinator library, I decided to implement the library myself. This parser is capable of parsing mathematical expressions, including addition, subtraction, multiplication, division, exponentiation and modulus. The parsed expressions are converted into an abstract syntax tree (AST), which is then evaluated using Peano arithmetic operations to calculate the final result.

## Interface: Read-Eval-Print Loop (REPL)

The interface for this project is a Read-Eval-Print Loop (REPL), allowing users to input mathematical expressions with or without parentheses. The parser follows the correct mathematical precedence rules to parse the expressions accurately. The output of the parser is the result of the Peano arithmetic operations on the given expression, providing a deeper understanding of both Peano arithmetic and OCaml's parser combinators.

## Getting Started

To get started with this project:

- Clone the repo to your local machine:
```bash
git clone git@github.com:zandacw/peanolator.git
```
- Navigate into the project directory:
```bash
cd peanolato
``` 

- Build the REPL and link the expression parser and Peano arithmetic libraries:
```bash
make main
```
- Run the REPL:
```bash
./main
```
## Contributing

Contributions to this project are welcome! If you have ideas for improvements or new features, feel free to open an issue or submit a pull request. Let's collaborate to make this project even better!

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
