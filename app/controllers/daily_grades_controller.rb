class DailyGradesController < ApplicationController
  respond_to :html, :json

  def index
    @student = Student.find(params[:student])
    @current_course = @student.courses.find_by(current: true)
    @past_courses = @student.courses.where(current: false)
    @current_semester = @current_course.semesters.first
    @current_daily_grades = @student.daily_grades.for_semester(@current_semester)
    @past_daily_grades = @student.daily_grades.for_past_semesters(@current_semester)
  end

  def show
    @daily_grade = DailyGrade.find(params[:id])
  end

  def new
    @daily_grade = DailyGrade.new
  end

  def create

  end

  def edit
    @daily_grade = DailyGrade.find(params[:id])
    @student = Student.find(@daily_grade.student_id)
  end

  def destroy

  end

  def update
    @daily_grade = DailyGrade.find(params[:id])
    student = Student.find(@daily_grade.student_id)

    respond_to do |format|
      if @daily_grade.update(daily_grade_params)
        format.html { redirect_to(daily_grades_path(student: student), :notice => 'Grade updated.') }
        format.json { respond_with_bip(@daily_grade)}
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@daily_grade) }
      end
    end
  end

  def attendance
    att_part_hw_grades
  end

  def update_attendance
    att_part_hw_update_grades

    respond_to do |format|
      if @daily_grade.update(daily_grade_params)
        format.html { render partial: "attendance" }
        format.js
      else
        flash.now[:alert] = "Error updating attendance. Please try again."
        format.html { render :edit }
      end
    end
  end

  def participation
    att_part_hw_grades
  end

  def update_participation
    att_part_hw_update_grades

    respond_to do |format|
      if @daily_grade.update(daily_grade_params)
        format.html { render partial: "participation" }
        format.js
      else
        flash.now[:alert] = "Error updating participation. Please try again."
        format.html { render :edit }
      end
    end
  end

  def homework
    att_part_hw_grades
  end

  def update_homework
    att_part_hw_update_grades

    respond_to do |format|
      if @daily_grade.update(daily_grade_params)
        format.html { render partial: "homework" }
        format.js
      else
        flash.now[:alert] = "Error updating homework. Please try again."
        format.html { render :edit }
      end
    end
  end

  def att_part_hw_grades
    @course = Course.find(params[:course_id])
    @students = @course.students.order(:family_name)
    @daily_grades_date = params[:date]&.to_date || @students.first.daily_grades.first.classdate.to_date
  end

  def att_part_hw_update_grades
    @course = Course.find(params[:course_id])
    @student = Student.find(params[:student_id])
    date = params[:date].to_date
    @daily_grade = @student.daily_grades.find_by(classdate: date.beginning_of_day..date.end_of_day)
  end

  private

  def daily_grade_params
    params.require(:daily_grade).permit(:attendance, :participation, :homework, :quiz, :comment, :exam, :classdate)
  end
end
