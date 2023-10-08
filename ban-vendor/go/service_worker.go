package main

import (
	"fmt"
	"log"
	"net/url"
	"strings"

	"github.com/fabioberger/chrome"
	"github.com/gopherjs/gopherjs/js"
)

var (
	console *js.Object     = js.Global.Get("console")
	c       *chrome.Chrome = chrome.NewChrome()
)

func main() {
	c.ContextMenus.Create(chrome.Object{
		"id":    "b66ec23a-7ec3-42bd-a2ce-b17934c38bd6",
		"title": "Add to the banned vendors",
		"contexts": []string{
			"link",
		},
	}, func() {
		console.Call("debug", "enter.context_menu.callback")
	})

	c.ContextMenus.OnClicked(func(info chrome.Object, tab chrome.Tab) {
		console.Call("debug", "enter.onclicked")
		console.Call("debug", info)

		vendor_id, err := getVendorId(info)
		if err {
			return
		}

		c.Tabs.SendMessage(
			tab.Id,
			chrome.Object{
				"vendor_id": vendor_id,
			},
			func(response chrome.Object) {
				console.Call("debug", "sw received", response)
			},
		)
	})
}

func getVendorId(info chrome.Object) (result string, errored bool) {
	vendorUrl := fmt.Sprintf("%v", info["linkUrl"])
	parsedUrl, err := url.Parse(vendorUrl)
	if err != nil {
		log.Fatal(err)
	}
	pathParts := strings.Split(parsedUrl.Path, "/")

	if len(pathParts) > 2 && pathParts[1] == "restaurant" {
		return pathParts[2], false
	}

	return
}
