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
    "longhorn",
    "mattermost",
    "mealie",
    "metube",
    "n8n",
    "obsidian",
    "pgadmin",
    "postgres",
    "qbittorrent",
    "wallos",
    "youtube",
  ]
}

variable "server" {
  type = string
}

variable "token" {
  type = string
}
