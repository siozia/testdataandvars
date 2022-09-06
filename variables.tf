
variable "provider_conf" {
    type = object({
        region=string
    })
}

variable "rds" {
  type = object(
    {
      confs = object({
        identifier = string
        db_password = string
      })
    }
  )
}