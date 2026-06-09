package main

import (
	"html/template"
	"log"
	"os"

	"github.com/mmcdole/gofeed"
)

const (
	blogRssFeed    = "https://cwchen-twn.github.io/rss.xml"
	maxPostsToShow = 5

	readmeTmplPath = "README.md.tmpl"
	readmePath     = "README.md"
)

func parseFeeds(rssFeed string) (*gofeed.Feed, error) {
	fp := gofeed.NewParser()
	feed, err := fp.ParseURL(rssFeed)
	if err != nil {
		return nil, err
	}
	return feed, nil
}

func main() {
	feed, err := parseFeeds(blogRssFeed)
	if err != nil {
		log.Printf("warning: could not fetch feed, skipping blog posts section: %v", err)
	}

	tmpl, err := template.ParseFiles(readmeTmplPath)
	if err != nil {
		log.Fatalf("create file: %v", err)
	}

	readme, err := os.Create(readmePath)
	if err != nil {
		log.Fatalf("create file: %v", err)
	}
	defer readme.Close()

	var items []*gofeed.Item
	if feed != nil {
		n := min(maxPostsToShow, len(feed.Items))
		items = feed.Items[0:n]
	}

	err = tmpl.Execute(readme, items)
	if err != nil {
		log.Fatalf("execute template: %v", err)
	}
}
