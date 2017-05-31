require 'sinatra'

# Base class for Whispers Web Application
class WispersBase < Sinatra::Base
  get '/account/:id/messages/?' do
    if current_account?(params)
      @messages = GetAllMessages.new(settings.config)
                                .call(current_account: @current_account,
                                      auth_token: @auth_token)
      p @messages
    end

    @messages ? slim(:messages_all) : redirect('/account/login')
  end

  get '/account/:id/messages/:message_id/?' do
    if current_account?(params)
      @message = GetMessageDetails.new(settings.config)
                                  .call(message_id: params[:message_id],
                                        auth_token: @auth_token)
      if @message
        slim(:message)
      else
        flash[:error] = 'We cannot find this message in your account'
        redirect "/account/#{params[:id]}/messages"
      end
    else
      redirect '/login'
    end
  end

  get '/account/:username/new_message/' do
    slim(:new_message)
  end

  post '/account/:id/new_message/?' do
    result = CreateMessage.new(settings.config).call(
      from_id: @current_account['id'].to_s,
      to_id: params[:id_input],
      title: params[:title_input],
      about: params[:about_input],
      expire_date: params[:expire_input],
      status: params[:status_input],
      body: params[:content_input]
    )
    if result
      redirect '/'
    else
      flash[:notice] = 'Public Key Faili, Please Input Again'
      redirect '/'
    end
    slim(:message_all)
  end
=begin
  post '/account/:username/projects/:project_id/collaborators/?' do
    halt_if_incorrect_user(params)

    collaborator = AddCollaboratorToProject.call(
      collaborator_email: params[:email],
      project_id: params[:project_id],
      auth_token: session[:auth_token])

    if collaborator
      account_info = "#{collaborator['username']} (#{collaborator['email']})"
      flash[:notice] = "Added #{account_info} to the project"
    else
      flash[:error] = "Could not add #{params['email']} to the project"
    end

    redirect back
  end


  post '/account/:username/projects/?' do
    halt_if_incorrect_user(params)

    projects_url = "/account/#{@current_account['username']}/projects"

    new_project_data = NewProject.call(params)
    if new_project_data.failure?
      flash[:error] = new_project_data.messages.values.join('; ')
      redirect projects_url
    else
      begin
        new_project = CreateNewProject.call(
          auth_token: session[:auth_token],
          owner: @current_account,
          new_project: new_project_data.to_h)
        flash[:notice] = 'Your new project has been created! '\
                         ' Now add configurations and invite collaborators.'
        redirect projects_url + "/#{new_project['id']}"
      rescue => e
        flash[:error] = 'Something went wrong -- we will look into it!'
        logger.error "NEW_PROJECT FAIL: #{e}"
        redirect "/account/#{@current_account['username']}/projects"
      end
    end
  end
=end
end
