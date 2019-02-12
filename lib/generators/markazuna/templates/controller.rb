require 'markazuna/api_cache'
require 'markazuna/di_container'
<%
    fields = ""
    for ii in 0..@fields.length-2 do
        fields = "#{fields}:#{@fields[ii]}, "
    end
    fields = "#{fields}:#{@fields[@fields.length-1]}"
%>
class <%= @class_name %>Controller < ApplicationController
    include Markazuna::APICache
    include Markazuna::INJECT['<%= @service_name %>']

    before_action   :authenticate
    after_action    :create_cache, only: [:index]

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :<%= singular_name %>, include: [<%= fields %>]

    # swagger api docs
    swagger_path '/<%= class_path[0] %>/<%= plural_file_name %>' do
        operation :post do
            key :summary, 'Please provide summary of this endpoint'
            key :description, 'Please provide description of this endpoint'
            key :operationId, 'add<%= singular_name.camelize %>'
            key :produces, [
                'application/json'
            ]
            key :tags, [
                '<%= singular_name %>'
            ]
            parameter do
                key :name, :core_user
                key :in, :body
                key :description, 'Please provide description'
                key :required, true
                schema do
                    key :'$ref', '<%= class_name %>Form'
                end
            end
            response 200 do
                key :description, 'Please provide description'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
            response :default do
                key :description, 'unexpected error'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
        end
    end
    def create
        <%= singular_name %>_form = <%= class_name %>Form.new(<%= singular_name %>_form_params)
        if <%= @service_name %>.create_<%= singular_name %>(<%= singular_name %>_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    swagger_path '/<%= class_path[0] %>/<%= plural_file_name %>' do
        operation :get do
            key :summary, 'Please provide summary of this endpoint'
            key :description, 'Please provide description of this endpoint'
            key :operationId, 'find<%= plural_name.camelize %>'
            key :produces, [
                'application/json',
                'text/html',
            ]
            key :tags, [
                '<%= singular_name %>'
            ]
            parameter do
                key :name, :uid
                key :in, :header
                key :description, 'UID'
                key :required, true
            end
            parameter do
                key :name, :authorization
                key :in, :header
                key :description, 'Bearer [Token]'
                key :required, true
            end
            response 200 do
                key :description, 'Please provide description'
                schema do
                    key :type, :array
                    items do
                        key :'$ref', '<%= class_name %>'
                    end
                end
            end
            response :default do
                key :description, 'unexpected error'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
        end
    end
    def index
        <%= plural_name %>, page_count = <%= @service_name %>.find_<%= plural_name %>(params[:page])
        if (<%= plural_name %>.size > 0)
            respond_to do |format|
                format.json { render :json => { results: <%= plural_name %>, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    swagger_path '/<%= class_path[0] %>/<%= plural_file_name %>/{id}' do
        operation :delete do
            key :summary, 'Please provide summary of this endpoint'
            key :description, 'Please provide description of this endpoint'
            key :operationId, 'delete<%= singular_name.camelize %>'
            key :produces, [
                'application/json',
                'text/html',
            ]
            key :tags, [
                '<%= singular_name %>'
            ]
            parameter do
                key :name, :uid
                key :in, :header
                key :description, 'UID'
                key :required, true
            end
            parameter do
                key :name, :authorization
                key :in, :header
                key :description, 'Bearer [Token]'
                key :required, true
            end
            parameter do
                key :name, :id
                key :in, :path
                key :description, 'Please provide description'
                key :required, true
            end
            response 200 do
                key :description, 'Please provide description'
            end
            response :default do
                key :description, 'unexpected error'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
        end
    end
    def destroy
        status, page_count = <%= @service_name %>.delete_<%= singular_name %>(params[:id])
        if status
            respond_to do |format|
                format.json { render :json => { status: "200", count: page_count } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    swagger_path '/<%= class_path[0] %>/<%= plural_file_name %>/{id}/edit' do
        operation :get do
            key :summary, 'Edit User'
            key :description, 'Edit user with certain id'
            key :operationId, 'edit<%= singular_name.camelize %>'
            key :produces, [
                'application/json',
                'text/html',
            ]
            key :tags, [
                '<%= singular_name %>'
            ]
            parameter do
                key :name, :uid
                key :in, :header
                key :description, 'UID'
                key :required, true
            end
            parameter do
                key :name, :authorization
                key :in, :header
                key :description, 'Bearer [Token]'
                key :required, true
            end
            parameter do
                key :name, :id
                key :in, :path
                key :description, 'Please provide description'
                key :required, true
            end
            response 200 do
                key :description, 'Please provide description'
                schema do
                    key :'$ref', '<%= class_name %>EditResponse'
                end
            end
            response :default do
                key :description, 'unexpected error'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
        end
    end
    def edit
        id = params[:id]
        <%= singular_name %> = <%= @service_name %>.find_<%= singular_name %>(id)

        if <%= singular_name %>
            respond_to do |format|
                format.json { render :json => { status: "200", payload: <%= singular_name %> } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    swagger_path '/<%= class_path[0] %>/<%= plural_file_name %>/{id}' do
        operation :put do
            key :summary, 'Update User'
            key :description, 'Update user with certain id'
            key :operationId, 'updateCoreUser'
            key :produces, [
                'application/json',
                'text/html',
            ]
            key :tags, [
                '<%= singular_name %>'
            ]
            parameter do
                key :name, :uid
                key :in, :header
                key :description, 'UID'
                key :required, true
            end
            parameter do
                key :name, :authorization
                key :in, :header
                key :description, 'Bearer [Token]'
                key :required, true
            end
            parameter do
                key :name, :core_user
                key :in, :body
                key :description, 'Please provide description'
                key :required, true
                schema do
                    key :'$ref', '<%= class_name %>Form'
                end
            end
            response 200 do
                key :description, 'Please provide description'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
            response :default do
                key :description, 'unexpected error'
                schema do
                    key :'$ref', 'Common::Response'
                end
            end
        end
    end
    def update
        <%= singular_name %>_form = <%= class_name %>Form.new(<%= singular_name %>_form_params)
        if <%= @service_name %>.update_<%= singular_name %>(<%= singular_name %>_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    private

    # Using strong parameters
    def <%= singular_name %>_form_params
        params.require(:<%= singular_name %>).permit(<%= fields %>)
        # params.require(:core_user).permit! # allow all
    end
end