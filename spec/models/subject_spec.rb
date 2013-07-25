# == Schema Information
#
# Table name: subjects
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  student_group_id :integer
#  start_date       :date
#

require 'spec_helper'

describe Subject do
  
  before(:each) do
    association_attr  
  end
  
  it "should create a new instance with valid attributes" do
    @student_group.subjects.new(@subject_attr).should be_valid
  end
  
  describe "validations" do
    
    it "should have a student_group_id" do
      Subject.new(@subject_attr).should_not be_valid
    end
    
    it "should have a name" do
      no_name_subject = @student_group.subjects.new(@subject_attr.merge(name: ""))
      no_name_subject.should_not be_valid
    end
    
    it "should have a start/end date" # do
    #       
    #     end
    
    it "should have an end date that is later than the start date" # do
    #       
    #     end
    
  end
  
  describe "Student_Group associations" do
    
    it "should have a student_group attribute" do
      @subject.should respond_to(:student_group)
    end
    
    it "should have the right associated student_group" do
      @subject.student_group_id.should == @student_group.id
      @subject.student_group.should == @student_group
    end 
    
  end
  
  describe "Goal associations" do
    
    it "should have a goal attribute" do
      @subject.should respond_to(:goals)
    end
    
    it "should destroy associated goals" do
      @subject.destroy
      [@goal, @goal2].each do |goal|
        Goal.find_by_id(goal.id).should be_nil
      end
    end
    
  end
    
end
