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

const (
	css_class_name string = "aa101509-5489-4495-91ec-11d02d5e061a"
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
		messageBoxed := message.(map[string]interface{})
		receivedVendorIdBoxed := messageBoxed["vendor_id"]
		receivedVendorId := fmt.Sprintf("%v", receivedVendorIdBoxed)
		receivedOperationBoxed := messageBoxed["operation"]
		receivedOperation := fmt.Sprintf("%v", receivedOperationBoxed)
		switch receivedOperation {
		case "add":
			bannedVendorIds = addIfNotExists(bannedVendorIds, receivedVendorId)
			break

		case "remove":
			for i := 0; i < len(bannedVendorIds); i++ {
				if bannedVendorIds[i] == receivedVendorId {
					bannedVendorIds = unorderedRemove(bannedVendorIds, i)
				}
			}
		}
		setBannedVendorIds(bannedVendorIds)
	})

	// TODO[PRIO-0]: make this eventful
	for true {
		banVendors(getBannedVendors())
		time.Sleep(1 * time.Second)
	}
}

func unorderedRemove(bannedVendorIds []string, i int) []string {
	newLength := len(bannedVendorIds) - 1
	bannedVendorIds[i] = bannedVendorIds[newLength]
	bannedVendorIds = bannedVendorIds[:newLength]
	return bannedVendorIds
}

func addIfNotExists(bannedVendorIds []string, receivedVendorId string) []string {
	for i := 0; i < len(bannedVendorIds); i++ {
		if bannedVendorIds[i] == receivedVendorId {
			return bannedVendorIds
		}
	}

	return append(bannedVendorIds, receivedVendorId)
}

func banVendors(bannedVendors []string) {
	// if len(banned_vendors) < 1 {
	// 	return
	// }

	vendors := dom.GetWindow().Document().DocumentElement().GetElementsByClassName("vendor-tile-wrapper")
	console.Call("debug", "vendors", vendors)
	for i := 0; i < len(vendors); i++ {
		vendors[i].Class().Remove(css_class_name)
		value := vendors[i].GetAttribute("data-testid")
		for j := 0; j < len(bannedVendors); j++ {
			if bannedVendors[j] == value {
				vendors[i].Class().Add(css_class_name)
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
