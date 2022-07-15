locals {
  instance_type = {
    stage = "10"
    prod  = "20"
  }
}

locals {
  instance_count = {
    stage = 1
    prod  = 2
  }
}

locals {
  instance_loop = {
    stage = 1
    prod  = 2
  }
}