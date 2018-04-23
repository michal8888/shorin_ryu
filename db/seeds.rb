users = []
10.times do
  users << "#{Faker::Name.first_name}@gmail.com"
end

users.uniq!

users.each do |user|
  User.create(email: user, login: user.slice(/\w+(?=@)/),
              password: "password", password_confirmation: "password")
end

10.times do
  zip_first = format("%.2d", rand(100))
  zip_second = format("%.3d", rand(1000))
  
  User.all
      .sample
      .events
      .create(name: Faker::App.name,
              address: { city: Faker::Address.city,
                         street: Faker::Address.street_name,
                         house_number: rand(100),
                         zip_code: "#{zip_first}-#{zip_second}" })
end

NAMES = ["2016 European Karate Championship", "WKF Karate Kumite 2017"]

NAMES.each { |ev_name| Event.create(user_id: User.all.sample, name: ev_name) }

ITEMS = [
          { 
           name: "White Karate Gi",
           price: 110, 
           description: "Very light material for great mobility. High quality. Mesh-Inlets for best ventilation. WKF Approved. 60% Cotton : 40% Polyester", 
           store_item_id: 300912,
           size: "m"
          }
        ]
ITEMS.each { |item| Item.create(item) }