# Домашнее задание к занятию "7.5. Основы golang"

[Источник](https://github.com/netology-code/virt-homeworks/blob/master/07-terraform-05-golang/README.md)

> С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
> Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
> 1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).

```bash
ansakoy@devnetbig:~$ go version
go version go1.18.3 linux/amd64
```

> 2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
> У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
> Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
> осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
> Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).
> 
> 1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
> у пользователя, а можно статически задать в коде.
>     Для взаимодействия с пользователем можно использовать функцию `Scanf`:
>     ```
>     package main
>     
>     import "fmt"
>     
>     func main() {
>         fmt.Print("Enter a number: ")
>         var input float64
>         fmt.Scanf("%f", &input)
>     
>         output := input * 2
>     
>         fmt.Println(output)    
>     }
>     ```
   
```go
package main

import "fmt"

// Напишите программу для перевода метров в футы (1 фут = 0.3048 метр)

func main() {
    fmt.Print("Enter a number (meters): ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input / 0.3048

    fmt.Println(output, "feet")    
}
```
```bash
ansakoy@devnetbig:~/goskripts$ go run task1.go 
Enter a number (meters): 15
49.212598425196845 feet
```
 
> 1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
>     ```
>     x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
>     ```

(сделано несколько по-питоновски по причине профдеформации и недостатке информации 
о хорошем тоне в go)
```go
package main

import "fmt"

func Min(nums []int) int {
    // Найти наименьший элемент в любом заданном списке
	min := nums[0]

	for _, i := range nums {
		if min > i {
			min = i
		}
	}
	return min
}

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	fmt.Println(Min(x))
}
```
```bash
ansakoy@devnetbig:~/goskripts$ go run task2.go 
9
```

> 1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 100; i++ {
		if i % 3 == 0 {
			fmt.Println(i)
		}
	}
}
```
```bash
ansakoy@devnetbig:~/goskripts$ go run task3.go 
3
6
9
12
15
18
21
24
27
30
33
36
39
42
45
48
51
54
57
60
63
66
69
72
75
78
81
84
87
90
93
96
99
```
> В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

> Создайте тесты для функций из предыдущего задания. 

