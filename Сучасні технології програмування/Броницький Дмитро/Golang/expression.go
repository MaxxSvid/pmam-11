package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

// Помилка ділення на нуль
type DivisionByZeroError struct{}

func (e *DivisionByZeroError) Error() string { return "Division by zero" }

// Помилка некоректного виразу
type InvalidExpressionError struct{ message string }

func (e *InvalidExpressionError) Error() string { return "Invalid expression: " + e.message }

// Інтерфейс для вузлів AST
type Node interface {
	Evaluate() (float64, error)           // Обчислення значення
	Prefix() string                       // Префіксна нотація
	Postfix() string                      // Постфіксна нотація
	String() string                       // Простий вивід
	FormattedString(indent string) string // Форматований вивід дерева
}

// Операнд — число
type Operand struct {
	value float64
}

func (o *Operand) Evaluate() (float64, error) { return o.value, nil }
func (o *Operand) Prefix() string             { return fmt.Sprintf("%g", o.value) }
func (o *Operand) Postfix() string            { return fmt.Sprintf("%g", o.value) }
func (o *Operand) String() string             { return fmt.Sprintf("%g", o.value) }

func (o *Operand) FormattedString(indent string) string {
	return fmt.Sprintf("%sOperand: %g", indent, o.value)
}

// Оператор — вузол дерева з лівим і правим піддеревами
type Operator struct {
	op    rune
	left  Node
	right Node
}

func (o *Operator) Evaluate() (float64, error) {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered from panic:", r)
		}
	}()

	leftVal, err := o.left.Evaluate()
	if err != nil {
		return 0, err
	}
	rightVal, err := o.right.Evaluate()
	if err != nil {
		return 0, err
	}
	switch o.op {
	case '+':
		return leftVal + rightVal, nil
	case '-':
		return leftVal - rightVal, nil
	case '*':
		return leftVal * rightVal, nil
	case '/':
		if rightVal == 0 {
			return 0, &DivisionByZeroError{}
		}
		return leftVal / rightVal, nil
	case '^':
		return math.Pow(leftVal, rightVal), nil
	default:
		return 0, &InvalidExpressionError{message: "unknown operator"}
	}
}

func (o *Operator) Prefix() string {
	return fmt.Sprintf("%c %s %s", o.op, o.left.Prefix(), o.right.Prefix())
}
func (o *Operator) Postfix() string {
	return fmt.Sprintf("%s %s %c", o.left.Postfix(), o.right.Postfix(), o.op)
}
func (o *Operator) String() string {
	return fmt.Sprintf("(%s %c %s)", o.left.String(), o.op, o.right.String())
}
func (o *Operator) FormattedString(indent string) string {
	return fmt.Sprintf("%sOperator: %c\n%s\n%s", indent, o.op, o.left.FormattedString(indent+"  "), o.right.FormattedString(indent+"  "))
}

func tokenize(expression string) ([]string, error) {
	var tokens []string
	var currentToken strings.Builder

	for _, ch := range expression {
		switch {
		case ch >= '0' && ch <= '9' || ch == '.':
			currentToken.WriteRune(ch)
		case strings.ContainsRune("+-*/^()", ch):
			if currentToken.Len() > 0 {
				tokens = append(tokens, currentToken.String())
				currentToken.Reset()
			}
			tokens = append(tokens, string(ch))
		case ch == ' ' || ch == '\t':
			if currentToken.Len() > 0 {
				tokens = append(tokens, currentToken.String())
				currentToken.Reset()
			}
		default:
			return nil, &InvalidExpressionError{message: fmt.Sprintf("invalid character: %q", ch)}
		}
	}

	if currentToken.Len() > 0 {
		tokens = append(tokens, currentToken.String())
	}
	return tokens, nil
}

func toPostfix(expression string) ([]string, error) {
	tokens, err := tokenize(expression)
	if err != nil {
		return nil, err
	}

	var result []string
	var stack []rune
	precedence := map[rune]int{'+': 1, '-': 1, '*': 2, '/': 2, '^': 3}

	for _, token := range tokens {
		if num, err := strconv.ParseFloat(token, 64); err == nil {
			result = append(result, fmt.Sprintf("%g", num))
		} else if token == "(" {
			stack = append(stack, '(')
		} else if token == ")" {
			for len(stack) > 0 && stack[len(stack)-1] != '(' {
				result = append(result, string(stack[len(stack)-1]))
				stack = stack[:len(stack)-1]
			}
			if len(stack) == 0 {
				return nil, &InvalidExpressionError{message: "mismatched parentheses"}
			}
			stack = stack[:len(stack)-1]
		} else if op := rune(token[0]); strings.ContainsRune("+-*/^", op) {
			for len(stack) > 0 && precedence[stack[len(stack)-1]] >= precedence[op] {
				if op == '^' && stack[len(stack)-1] == '^' {
					break
				}
				result = append(result, string(stack[len(stack)-1]))
				stack = stack[:len(stack)-1]
			}
			stack = append(stack, op)
		} else {
			return nil, &InvalidExpressionError{message: "invalid token " + token}
		}
	}
	for len(stack) > 0 {
		result = append(result, string(stack[len(stack)-1]))
		stack = stack[:len(stack)-1]
	}
	return result, nil
}

// Побудова AST з постфіксної нотації
func buildAST(postfix []string) (Node, error) {
	var stack []Node
	for _, token := range postfix {
		if num, err := strconv.ParseFloat(token, 64); err == nil {
			stack = append(stack, &Operand{value: num})
		} else if len(token) == 1 && strings.ContainsRune("+-*/^", rune(token[0])) {
			if len(stack) < 2 {
				return nil, &InvalidExpressionError{message: "insufficient operands"}
			}
			right := stack[len(stack)-1]
			left := stack[len(stack)-2]
			stack = stack[:len(stack)-2]
			stack = append(stack, &Operator{op: rune(token[0]), left: left, right: right})
		} else {
			return nil, &InvalidExpressionError{message: "invalid token in AST build"}
		}
	}
	if len(stack) != 1 {
		return nil, &InvalidExpressionError{message: "malformed expression"}
	}
	return stack[0], nil
}
