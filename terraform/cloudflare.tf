resource "cloudflare_record" "wildcard" {
  zone_id  = "90120ede4956d821d37e4843d5c1c0d6"
  name     = "*"
  type     = "CNAME"
  value    = "af5222aafb6ee41a184c96bf3a10c1cc-82da0b8cd799a5bd.elb.eu-central-1.amazonaws.com"
}