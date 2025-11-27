package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	fmt.Print("Enter an expression: ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	expression := scanner.Text()

	// Конвертуємо інфіксну нотацію в постфіксну
	postfix, err := toPostfix(expression)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	// Створюємо AST з постфіксної нотації
	ast, err := buildAST(postfix)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	// Виводимо результати в різних нотаціях
	fmt.Println("Prefix notation:", ast.Prefix())
	fmt.Println("Postfix notation:", ast.Postfix())
	fmt.Println("AST structure (formatted):\n", ast.FormattedString(""))

	// Обчислюємо результат виразу
	result, err := ast.Evaluate()
	if err != nil {
		fmt.Println("Evaluation error:", err)
	} else {
		fmt.Println("Result:", result)
	}
}
