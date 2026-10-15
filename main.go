package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/tulir/whatsmeow"
	waProto "go.mau.fi/whatsmeow/binary/proto"
	"go.mau.fi/whatsmeow/store/sqlite"
	waLog "go.mau.fi/whatsmeow/util/log"
)

var allowlist = map[string]bool{
	"919820056180": true,
}

func main() {
	// Health endpoint for Coolify
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true, "status": "live"})
	})
	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Custom WhatsApp Agent is running")
	})

	go func() {
		log.Println("Starting WhatsApp client...")
		if err := runWhatsApp(); err != nil {
			log.Fatalf("WhatsApp error: %v", err)
		}
	}()

	port := os.Getenv("PORT")
	if port == "" {
		port = "18789"
	}
	log.Printf("HTTP server listening on :%s", port)
	r.Run(":" + port)
}

func runWhatsApp() error {
	dbLog := waLog.Stdout("Database", "INFO", true)
	deviceStore, err := sqlite.Open("wa.db", "localhost")
	if err != nil {
		return err
	}
	deviceStore.Logger = waLog.Stdout("Store", "ERROR", true)

	clientLog := waLog.Stdout("Client", "INFO", true)
	client := whatsmeow.NewClient(deviceStore, clientLog)

	if client.Store.ID == nil {
		qrChan, _ := client.GetQRChannel(context.Background())
		go func() {
			for evt := range qrChan {
				if evt.Event == "code" {
					fmt.Printf("Scan QR: %s\n", evt.Code)
				}
			}
		}()
		if err := client.Connect(); err != nil {
			return err
		}
	} else {
		if err := client.Connect(); err != nil {
			return err
		}
	}

	// Handle incoming messages
	client.AddEventHandler(func(evt interface{}) {
		switch v := evt.(type) {
		case *whatsmeow.Disconnected:
			log.Printf("Disconnected: %v", v)
		case *waProto.WebMessageInfo:
			if v.Message == nil || v.Message.GetConversation() == "" {
				return
			}
			senderJID := v.GetPushName()
			remoteJID := v.GetKey().GetRemoteJid()
			if remoteJID == "" {
				return
			}
			// Extract numeric part
			sender := strings.Split(remoteJID, "@")[0]
			if !allowlist[sender] {
				log.Printf("Ignored message from non-allowlisted %s", sender)
				return
			}
			if strings.HasSuffix(remoteJID, "@g.us") {
				log.Printf("Ignored group message")
				return
			}
			text := v.Message.GetConversation()
			log.Printf("Message from %s: %s", sender, text)
			// Simple echo reply
			reply := fmt.Sprintf("Echo: %s", text)
			_, err := client.SendMessage(context.Background(), waProto.JID{User: remoteJID}, &waProto.Message{
				Conversation: &reply,
			})
			if err != nil {
				log.Printf("Failed to send reply: %v", err)
			}
		}
	})

	select {}
}
