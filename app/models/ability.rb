class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :read, :edit, :update, :create, :destroy, :to => :manage_own
    alias_action :read, :edit, :update, :create, :destroy, :to => :manage_department
    alias_action :read_own, :edit, :update, :to => :manage_own_excluding_creation

    user ||= User.new
    if user.new_record?
      user.role = Role.where(const_name: 'anonymous').first
    else
      can :manage, :my
    end

    if user.anonymous?
      can :read, Diamond::Thesis
    elsif user.student?
      can :manage, User,
        {:id => user.id }
      can :read, Diamond::Thesis
      can :create, Diamond::ThesisEnrollment
    elsif user.supervisor?
      can :manage, User,
        {:id => user.id }
      can :manage_own, Diamond::Thesis,
        {:supervisor_id => user.verifable_id}
      can :manage, Diamond::ThesisEnrollment,
        {:thesis => {:supervisor_id => user.verifable_id}}
      can :manage, Diamond::ThesisMessage
    elsif user.department_admin?
      can :manage_department, Diamond::Thesis,
        {:department_id => user.verifable.department_id}
      can :manage, User,
        {:id => user.id }
      can :manage, Diamond::ThesisEnrollment
      can :manage, Diamond::ThesisMessage
      can :manage, DepartmentSettings,
        {:department_id => user.verifable.department_id}
    elsif user.admin?
      can :manage, User
      can :manage, Diamond::Thesis
      can :manage, Diamond::ThesisEnrollment
      can :manage, Diamond::ThesisMessage
      can :manage, EnrollmentSemester
    elsif user.superadmin?
      can :manage, :all
    end

  end

end
