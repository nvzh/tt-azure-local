# output "username" {
#   value = random_pet.mke_username
# }

output "password" {
  value = random_string.mke_password.result
}