# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Doorkeeper::Application.create!(
  {
    name: "MyAuth",
    uid: "Vc4RA6fYjCcOjjaTWcj-XZDyBMEm3Jbzs6ov_Q55hYQ",
    secret: "Zv2RqMbS8ijWt9_aeuP2z0NYhnXHM0pEJyGAansxcPk",
    redirect_uri: "http://localhost:3010/accounts/auth/doorkeeper/callback\r\nhttp://localhost:3020/accounts/auth/doorkeeper/callback\r\nhttp://localhost:3030/accounts/auth/doorkeeper/callback",
    scopes: "read",
    confidential: true,
  },
)