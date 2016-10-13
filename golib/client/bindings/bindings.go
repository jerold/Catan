package main

import "github.com/gopherjs/gopherjs/js"

func main() {
	js.Global.Set("catannet", map[string]interface{}{
		"NewClient": newClient,
	})
}
