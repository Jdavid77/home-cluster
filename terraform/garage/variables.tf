variable "buckets" {
  description = "Set of S3 bucket names"
  type        = set(string)
  default = [
    "adventurelog",
    "akeyless-backups",
    "audiobookshelf",
    "calibre-web",
    "dashy",
    "filebrowser",
    "gotify",
    "homebox",
    "linkding",
    "mattermost",
    "mealie",
    "metube",
    "n8n",
    "obsidian",
    "pgadmin",
    "postgresus",
    "postgres",
    "qbittorrent",
    "wallos",
    "youtube",
    "excalidash",
    "booklore",
    "mariadb",
    "trip",
    "expenseowl",
    "grist",
    "renderercv",
    "ephemera",
    "shelfmark"
  ]
}

variable "server" {
  type = string
}

variable "token" {
  type = string
}
