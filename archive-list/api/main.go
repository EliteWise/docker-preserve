package main

import (
	docs "module/docs"
	"net/http"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	r := gin.Default()
	docs.SwaggerInfo.BasePath = "/api/v1"
	v1 := r.Group("/api/v1")
	{
		eg := v1.Group("/archives")
		{
			eg.GET("/archives", getArchives)
			eg.GET("/archive/:id", getArchive)
			eg.DELETE("/archive/:id", deleteArchive)
		}
	}
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	r.Run("localhost:8080")
}

// @BasePath /api/v1

// GetArchives godoc
// @Summary Retrieve a list of all archives
// @Description Retrieve a list of all archives
// @Tags Archives
// @Produce json
// @Success 200 {object} string "Successfully retrieved list of archives"
// @Failure 404 {object} string "Archives not found"
// @Router /archives [get]
func getArchives(c *gin.Context) {
	c.JSON(http.StatusOK, "Json for all the archives")
}

// @BasePath /api/v1

// GetArchive godoc
// @Summary Retrieve a specific archive
// @Description Retrieve a specific archive
// @Tags Archives
// @Produce json
// @Param id path int true "Identifier for the archive"
// @Success 200 {string} string "Successfully retrieved archive"
// @Failure 404 {object} string "Archive not found"
// @Router /archive/{id} [get]
func getArchive(c *gin.Context) {
	id := c.Param("id")
	c.JSON(http.StatusOK, "Json for one archive "+id)
}

// @BasePath /api/v1

// PingExample godoc
// @Summary Delete a specific archive
// @Description Delete a specific archive
// @Tags Archives
// @Produce json
// @Param id path int true "Identifier for the archive to be deleted"
// @Success 200 {string} string "Successfully deleted archive"
// @Failure 404 {object} string "Archive not found"
// @Router /deleteArchive/{id} [delete]
func deleteArchive(c *gin.Context) {
	id := c.Param("id")
	c.String(http.StatusOK, "The archive that was deleted "+id)
}
