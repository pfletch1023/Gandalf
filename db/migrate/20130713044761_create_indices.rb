class CreateIndices < ActiveRecord::Migration
  def change
        
    # User Indices.
    change_table :users do |t|
      t.index :netid
      t.index :email
    end
    
    # Organization indices.
    change_table :organizations do |t|
      t.index :slug
    end
    
    # Subscription indices
    change_table :subscriptions do |t|
      t.index :subscribeable_id
      t.index :group_id
      t.index :user_id
    end
    
    # Event indices
    change_table :events do |t|
      t.index :slug
      t.index :organization_id
    end
    
    # Event instances indices
    change_table :event_instances do |t|
      t.index :apps_id
      t.index :group_id
      t.index :event_id
    end
    
    # Group indices
    change_table :groups do |t|
      t.index :slug
      t.index :organization_id
      t.index :apps_id
    end
  end
end

