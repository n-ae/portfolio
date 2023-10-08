package main

import (
	"fmt"
	"time"

	"github.com/fabioberger/chrome"
	"github.com/gopherjs/gopherjs/js"
	"honnef.co/go/js/dom"
)

var (
	console *js.Object     = js.Global.Get("console")
	c       *chrome.Chrome = chrome.NewChrome()
)

func main() {
	createBannedVendorSetIfNotExists()
	console.Call("debug", "extension_id", c.Runtime.Id)

	c.Runtime.OnMessage(func(message interface{}, sender chrome.MessageSender, sendResponse func(interface{})) {
		console.Call("debug", "cs received", message, sender, sendResponse)
		// sender is not our service worker
		if sender.Id != c.Runtime.Id {
			return
		}

		bannedVendorIds := getBannedVendorsIds()
		receivedVendorIdBoxed := message.(map[string]interface{})["vendor_id"]
		receivedVendorId := fmt.Sprintf("%v", receivedVendorIdBoxed)
		for i := 0; i < len(bannedVendorIds); i++ {
			if bannedVendorIds[i] == receivedVendorId {
				return
			}
		}

		bannedVendorIds = append(bannedVendorIds, receivedVendorId)
		setBannedVendorIds(bannedVendorIds)
	})

	for true {
		removeVens(getBannedVendors())
		time.Sleep(1 * time.Second)
	}
}

func removeVens(banned_vendors []string) {
	if len(banned_vendors) < 1 {
		return
	}

	vendors := dom.GetWindow().Document().DocumentElement().GetElementsByClassName("vendor-tile-wrapper")
	console.Call("debug", "vendors", vendors)
	for i := 0; i < len(vendors); i++ {
		value := vendors[i].GetAttribute("data-testid")
		for j := 0; j < len(banned_vendors); j++ {
			if banned_vendors[j] == value {
				vendors[i].Remove()
			}
		}
	}
}

func createBannedVendorSetIfNotExists() {
	val := getBannedVendorIdsBoxed()
	if val != nil {
		console.Call("debug", "key already exists")
		console.Call("debug", val)
		return
	}

	setBannedVendorIds([]string{})
	console.Call("debug", "assigned key")
}

func getBannedVendorIdsBoxed() []interface{} {
	const key = "banned_vendors_ys"
	val, _ := c.Storage.Sync.Get(key).Interface().([]interface{})
	return val
}

func getBannedVendorsIds() []string {
	bannedVendorsObject := getBannedVendorIdsBoxed()
	result := make([]string, len(bannedVendorsObject))
	for i, v := range bannedVendorsObject {
		result[i] = fmt.Sprintf("%v", v)
	}
	return result
}

func setBannedVendorIds(vendors []string) {
	const key = "banned_vendors_ys"
	c.Storage.Sync.Set(key, vendors)
}

func getBannedVendors() []string {
	bannedVendorsObject := getBannedVendorIdsBoxed()
	console.Call("debug", bannedVendorsObject)

	bannedVendors := make([]string, len(bannedVendorsObject))
	for i, v := range bannedVendorsObject {
		bannedVendors[i] = fmt.Sprintf("vendor-%v", v)
	}
	return bannedVendors
}
