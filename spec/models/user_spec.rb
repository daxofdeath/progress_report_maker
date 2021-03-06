# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)
#  salt                   :string(255)
#  admin                  :boolean          default(FALSE)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#

require 'spec_helper'

describe User do
  
  before(:each) do
    @user = User.new(@user_attr)
    @user_attr = {
      name:                  "user", 
      email:                 "User@Example.com", 
      password:              "password",
      password_confirmation: "password"
    }
  end
  
  it "should create a new instance given a valid attribute" do
    User.create!(@user_attr).should be_valid
  end
 
  # name
  
  it "should require a name" do
    no_name_user = User.new(@user_attr.merge(name: ""))
    no_name_user.should_not be_valid
  end 
  
  it "should require a name between 3 and 40 characters" do
    long_name = "a" * 41
    short_name = "a" * 2
    wrong_namelength_user = User.new(@user_attr.merge(name: long_name) || User.new(@user_attr.merge(name: short_name)))
    wrong_namelength_user.should_not be_valid
  end
  
  it "should be titleized" do
    user = User.create(@user_attr)
    user.name.should eq('User')
  end
  
  # email
  
  it "should require an email address" do
    no_email_user = User.new(@user_attr.merge(email: ""))
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@domain.com THE_USER_123@domain.co.uk first.last@domain.com user+filter@domain.com user-x@domain.com user@domain-name.com user@1domain.com]
    addresses.each do |address|
      valid_email_user = User.new(@user_attr.merge(email: address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
     addresses = %w[user_at_domain.com THE USER_123(at)domain.co.uk first.last@com user@domain. user@domain,com]
     addresses.each do |address|
       invalid_email_user = User.new(@user_attr.merge(email: address))
       invalid_email_user.should_not be_valid
     end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@user_attr)
    duplicate_email_user = User.new(@user_attr)
    duplicate_email_user.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    User.create!(@user_attr.merge(:email => @user_attr[:email].upcase))
    duplicate_email_user = User.new(@user_attr)
    duplicate_email_user.should_not be_valid
  end
  
  it "should be downcased" do
    user = User.create(@user_attr)
    user.email.should eq('user@example.com')
  end
  
  # passwords/authentication
  
  describe "passwords" do
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    
    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  
    describe "password validations" do
    
    it "should require a password" do
      User.new(@user_attr.merge(:password => "", :password_confirmation => "")).should_not be_valid      
    end
    
    it "should require a matching password confirmation" do
      User.new(@user_attr.merge(:password_confirmation => "wrong_password")).should_not be_valid
    end
    
    it "should require a password between 6 and 15 characters" do
      long_pass = "a" * 16
      short_pass = "a" * 5

      wrong_passlength_user = User.new(@user_attr.merge(password: long_pass, password_confirmation: long_pass) || User.new(@user_attr.merge(password: short_pass, password_confirmation: short_pass)))
      wrong_passlength_user.should_not be_valid
    end
  
  end
  
    describe "password encryption" do
    before(:each) do
       @user = User.create!(@user_attr)
     end

     it "should have an encrypted password attribute" do
       @user.should respond_to(:encrypted_password)
     end

     it "should write the encypted password to the database" do
       @user.encrypted_password.should_not be_blank
     end

     describe "has_password? method" do

       it "should exist" do
         @user.should respond_to(:has_password?)
       end

       it "should return 'true' if the passwords match" do
         @user.has_password?(@user_attr[:password]).should be_true
       end

       it "should have a salt" do
         @user.should respond_to(:salt)
       end
     end   
  end

    describe "authenticate method" do
    
    before(:each) do
      @user = User.create!(@user_attr)
    end
    
    it "should exist" do
      User.should respond_to(:authenticate)
    end
    
    it "should return 'nil' on email/password mismatch" do
      User.authenticate(@user_attr[:email], "wrong_password").should be_nil
    end
    
    it "should return 'nil' for an email address with no user" do
      User.authenticate("user@nil.com", @user_attr[:password]).should be_nil
    end
    
    it "should return the user on email/password match" do
      User.authenticate(@user_attr[:email], @user_attr[:password]).should == @user
    end
    
  end

  end
  
  # admin
  
  describe "admin users" do
    
    before(:each) do
      @user = User.create!(@user_attr)
    end
    
    it "should respond to 'admin'" do
      @user.should respond_to(:admin)
    end
    
    it "should not be default" do
      @user.should_not be_admin
    end
    
  end

  # student_group association

  describe "student_group associations" do
    
    before(:each) do
      association_attr
    end
    
    it "should have a student_groups attribute" do
      @user.should respond_to(:student_groups)
    end
    
    it "should destroy associated student_groups" do
      @user.destroy
      [@student_group, @student_group2].each do |student_group|
        StudentGroup.find_by_id(student_group.id).should be_nil
      end
    end
    
  end

  # password reset
  
  describe "#send_password_reset" do
    
    let(:user) { FactoryGirl.create(:user)}

      it "generates a unique password_reset_token each time" do
        user.send_password_reset
        last_token = user.password_reset_token
        user.send_password_reset
        user.password_reset_token.should_not eq(last_token)
      end

      it "saves the time the password reset was sent" do
        user.send_password_reset
        user.reload.password_reset_sent_at.should be_present
      end

      it "delivers email to user" do
        user.send_password_reset
        ActionMailer::Base.deliveries.last.to.should include(user.email)
      end
      
  end
  
  
end
