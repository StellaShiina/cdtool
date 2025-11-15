package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"

	"github.com/gin-gonic/gin"
)

func main() {
	gin.SetMode(gin.ReleaseMode)

	r := gin.Default()

	r.POST("/", func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization header format. Expected: Bearer <token>"})
			c.Abort()
			return
		}

		token := parts[1]

		if !(os.Getenv("CD_TOKEN") == token) {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		cmd := exec.Command("bash", "-l", os.Getenv("CD_SCRIPT_PATH"))
		out, err := cmd.Output()
		if err != nil {
			fmt.Println("Error:", err)
		}
		fmt.Println(string(out))
		c.String(http.StatusCreated, string(out))
	})

	r.SetTrustedProxies([]string{"127.0.0.1", "::1"})

	r.Run("localhost:" + os.Getenv("PORT"))
}
