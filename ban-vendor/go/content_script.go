package main

import (
	"time"

	"github.com/gopherjs/gopherjs/js"
	"honnef.co/go/js/dom"
)

var (
	console *js.Object = js.Global.Get("console")
)

func main() {
	banned_vendors := []string{
		"vendor-ylk7",
	}

	for true {
		removeVens(banned_vendors)
		time.Sleep(100 * time.Millisecond)
	}
}

func removeVens(banned_vendors []string) {
	vendors := dom.GetWindow().Document().DocumentElement().GetElementsByClassName("vendor-tile-wrapper")
	// console.Call("log", vendors)
	for i := 0; i < len(vendors); i++ {
		value := vendors[i].GetAttribute("data-testid")
		for j := 0; j < len(banned_vendors); j++ {
			if banned_vendors[j] == value {
				vendors[i].Remove()
			}
		}
	}
}
