variable "buckets" {
  description = "Set of S3 bucket names"
  type        = set(string)
  default = [
    "adventurelog",
    "akeyless-backups",
    "audiobookshelf",
    "filebrowser",
    "linkding",
    "mealie",
    "metube",
    "n8n",
    "pgadmin",
    "postgres",
    "qbittorrent",
    "wallos",
    "youtube",
    "excalidash",
    "booklore",
    "mariadb",
    "grist",
    "renderercv",
    "shelfmark",
    "zot"
  ]
}

