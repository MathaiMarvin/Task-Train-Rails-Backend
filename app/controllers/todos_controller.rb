class TodosController < ApplicationController
    before_action :session_expired?

    def create
        todo = user.todos.create(todo_params)
        if todo.valid?
            app_response(status: :created, data: todo)
        else
            app_response(status: :unprocessable_entity, data: todo.errors, message: "failed")
        end
    end

    def update
        todo = user.todos.find(params[:id]).update(todo_params)

        if todo
            app_response(data: {info: "updated Successfully"})
        else
            app_response(message: 'failed', data: {info: "Something went wrong. Could not update todo"}, status: :unprocessable_entity)
        end
    end

    def destroy
        todo = user.todos.find(params[:id]).destroy
        app_response(message: "success", data: {info: "deleted successfully"}, status: 204)
    end

    private
    def todo_params
        params.permit(:title, :description, :status, :priority)
    end
end
