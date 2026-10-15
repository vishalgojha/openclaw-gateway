package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true, "status": "live", "service": "custom-whatsapp-agent"})
	})
	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Custom WhatsApp Agent is running")
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "18789"
	}
	log.Printf("HTTP server listening on :%s", port)
	r.Run(":" + port)
}
