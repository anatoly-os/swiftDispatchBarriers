# swiftDispatchBarriers
Demonstrating how to control both heavy operations and UI interactive actions with a predictable output.

## English

## Russian
Этот проект показывает, как можно использовать concurrent custom dispatch queues для решения продуктовой задачи.
Когда одновременно выполняются тяжелые операции, при этом UI остается интерактивным.

### Контекст приложения

1. Написать приложение, которое выводит на экран 10 квадратов белого цвета.
2. Далее после запуска, не блокируя UI, цвета меняются на случайные*.
2а. * Изменение цветов - heavy operation, которое может занимать несколько секунд (зафейкать это поведение).
3. Так же в UI присутствует кнопка, позволяющая изменить цвет любого квадрата на случайный. Это может быть как heavy операцией, так и нет.
4. UI никогда не должен "зависать" - кнопка должна нажиматься.

#### Постановка задачи
Необходимо средствами многопоточности сделать так, чтобы нажатие на кнопку не меняло цвета квадратов, пока они все не станут "не белыми", то есть пока алгоритм изменения цветов (2) не отработает.


## Solution

UI stays interactive. Pressing the button doesn't change the colors until the algo finishes. DispatchBarrier makes it possible (the code in `master` branch):

https://user-images.githubusercontent.com/18065034/195635687-01b0ed3d-8d87-455b-aa68-032d7b89e37b.mp4

The same code, but without using DispatchBarrier on the working concurrent custom queue (uncomment Line 44 in ContentView.swift file, and comment Line 43):

https://user-images.githubusercontent.com/18065034/195635657-f87ca903-5f45-4997-85ae-9ab309ad1bc2.mp4
