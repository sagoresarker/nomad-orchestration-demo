package main

import (
    "fmt"
    "time"
)

func main() {
    for {
        fmt.Println("Go binary is running...")
        time.Sleep(5 * time.Second)
    }
}
