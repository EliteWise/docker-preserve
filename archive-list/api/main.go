package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/test1", test1)
	router.GET("/test2", test2)
	router.Run("localhost:8080")
}

func test1(c *gin.Context) {
	c.String(http.StatusOK, "test1")
}

func test2(c *gin.Context) {
	c.String(http.StatusOK, "test1")
}
