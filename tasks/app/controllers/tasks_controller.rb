class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy close]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all
    @my_tasks = Task.where(account_id: current_account.id)
  end

  # GET /tasks/1 or /tasks/1.json
  def show; end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit; end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)
    @task.account = Account.where(role: "worker").sample

    respond_to do |format|
      if @task.save
        @task.reload
        # ----------------------------- produce event -----------------------
        event = {
          **task_event_data.merge(event_version: 2),
          event_name: "TaskCreated",
          data: {
            public_id: @task.public_id,
            title: @task.title,
            jira_id: @task.jira_id,
            description: @task.description,
            status: @task.status,
            account_public_id: @task.account.public_id,
          },
        }

        result = SchemaRegistry.validate_event(event, "tasks.created", version: 2)

        Producer.new.call(event, topic: "tasks-stream") if result.success?
        # --------------------------------------------------------------------

        format.html { redirect_to tasks_url, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        # ----------------------------- produce event -----------------------
        event = {
          **task_event_data.merge(event_version: 2),
          event_name: "TaskUpdated",
          data: {
            public_id: @task.public_id,
            title: @task.title,
            jira_id: @task.jira_id,
            description: @task.description,
            status: @task.status,
            account_public_id: @task.account.public_id,
          },
        }

        result = SchemaRegistry.validate_event(event, "tasks.updated", version: 2)

        Producer.new.call(event, topic: "tasks-stream") if result.success?
        # --------------------------------------------------------------------

        format.html { redirect_to task_url(@task), notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy

    # ----------------------------- produce event -----------------------
    event = {
      **task_event_data,
      event_name: "TaskDeleted",
      data: { public_id: @task.public_id },
    }
    Producer.new.call(event, topic: "tasks-stream")
    # --------------------------------------------------------------------

    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def reshuffle
    accounts = Account.where(role: "worker")
    tasks = Task.where(status: "open")
    tasks.each do |task|
      account = accounts.sample
      task.update_columns(account_id: account.id)
      # ----------------------------- produce event -----------------------
      event = {
        **task_event_data,
        event_name: "TaskReshuffled",
        data: {
          public_id: task.public_id,
          account_public_id: account.public_id,
        },
      }
      Producer.new.call(event, topic: "tasks")
      # --------------------------------------------------------------------
    end
    redirect_to tasks_url, notice: "Задачи успешно заасайнены"
  end

  def close
    @task.update(status: "close")
    # ----------------------------- produce event -----------------------
    event = {
      **task_event_data,
      event_name: "TaskClosed",
      data: {
        public_id: @task.public_id,
        account_public_id: current_account.public_id,
      },
    }
    Producer.new.call(event, topic: "tasks")
    # --------------------------------------------------------------------
    redirect_to tasks_url
  end

  private

  def task_event_data
    {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.zone.now.to_s,
      producer: "tasks_service",
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :jira_id, :description)
  end
end
