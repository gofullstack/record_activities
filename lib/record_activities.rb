class ActiveRecord::Base
  def self.record_activities(*actions)
    #association
    options = actions.extract_options!
    if options[:dependent] or options[:association]
      name = options[:association] || :activities
      dependent = options[:dependent] || :nullify
      has_many name, :dependent => dependent, :as => :subject, :class_name => 'Activity'
    end

    #action recording
    actions = [:create, :update] if actions.empty?
    actions.each do |action|
      method = "record_activity_#{action}".to_sym
      define_method method do
        return unless self.class.record_userstamp
        Activity.create(
          :actor_id => self.class.stamper_class.stamper,
          :subject  => self,
          :action   => action.to_s,
          # record changed attributes but only for updates
          :changed_attributes  => (action == :update ? (self.changes.inspect rescue nil) : nil)
        )
      end
      send("after_#{action}",method) if respond_to?("after_#{action}")
    end
  end
end