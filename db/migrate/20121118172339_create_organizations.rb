class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      
      # Gandalf Attributes.
      t.string :name
      t.text :bio
      t.string :slug
      t.string :image
      t.string :color, :default => "150,150,150" # format r,g,b

      # Facebook Attributes.
      t.string :fb_id
      t.string :fb_access_key
      t.string :fb_name
      t.string :fb_link
      
      # Rails Attributes.
      t.timestamps
    end
  end
end

