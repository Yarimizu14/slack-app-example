require 'rest-client'

class Slack::ShortcutsController < ApplicationController
  before_action :get_user, only: [:create]

  # POST /shortcuts
  #
  # type = shortcut
  # {
  #   "type": "shortcut",
  #   "token": "xxxxxxxxxxxxxxxxxxxxxxxx",
  #   "action_ts": "1602812392.991436",
  #   "team": {
  #     "id": "TTTTTTTTT",
  #     "domain": "domain-name"
  #   },
  #   "user": {
  #     "id": "UUUUUUUUU",
  #     "username": "someone",
  #     "team_id": "TTTTTTTTT"
  #   },
  #   "callback_id": "callbackname",
  #   "trigger_id": "1111111111111.22222222222.33333333333333333333333333333333"
  # }
  #
  # type = view_submission
  # {
  #   "type": "view_submission",
  #   "team": {
  #     "id": "TTTTTTTTT",
  #     "domain": "domain-name"
  #   },
  #   "user": {
  #     "id": "UUUUUUUUU",
  #     "username": "username",
  #     "name": "username",
  #     "team_id": "TTTTTTTT"
  #   },
  #   "api_app_id": "AAAAAAAAAAA",
  #   "token": "tttttttttttttttttttttttt",
  #   "trigger_id": "9999999999999999999999999999999999999999999999999999999999",
  #   "view": {
  #     "id": "VVVVVVVVVV",
  #     "team_id": "TTTTTTTTT",
  #     "type": "modal",
  #     "blocks": [
  #       {
  #         "type": "section",
  #         "block_id": "project_block",
  #         "text": {
  #           "type": "plain_text",
  #           "text": "Pick an item from the dropdown list",
  #           "emoji": true
  #         },
  #         "accessory": {
  #           "type": "static_select",
  #           "action_id": "select_project",
  #           "placeholder": {
  #             "type": "plain_text",
  #             "text": "which project do you subscribe?",
  #             "emoji": true
  #           },
  #           "options": [
  #             {
  #               "text": {
  #                 "type": "plain_text",
  #                 "text": "project1",
  #                 "emoji": true
  #               },
  #               "value": "1"
  #             }
  #           ]
  #         }
  #       },
  #       {
  #         "type": "input",
  #         "block_id": "channel_block",
  #         "label": {
  #           "type": "plain_text",
  #           "text": "Channel(s)",
  #           "emoji": true
  #         },
  #         "optional": false,
  #         "dispatch_action": false,
  #         "element": {
  #           "type": "multi_channels_select",
  #           "action_id": "channels",
  #           "placeholder": {
  #             "type": "plain_text",
  #             "text": "which channel to subscribe?",
  #             "emoji": true
  #           }
  #         }
  #       }
  #     ],
  #     "private_metadata": "",
  #     "callback_id": "",
  #     "state": {
  #       "values": {
  #         "project_block": {
  #           "select_project": {
  #             "type": "static_select",
  #             "selected_option": {
  #               "text": {
  #                 "type": "plain_text",
  #                 "text": "project1",
  #                 "emoji": true
  #               },
  #               "value": "1"
  #             }
  #           }
  #         },
  #         "channel_block": {
  #           "channels": {
  #             "type": "multi_channels_select",
  #             "selected_channels": [
  #               "CCCCCCCCC"
  #             ]
  #           }
  #         }
  #       }
  #     },
  #     "hash": "1111111111.hhhhhhhh",
  #     "title": {
  #       "type": "plain_text",
  #       "text": "Project Subscription",
  #       "emoji": true
  #     },
  #     "clear_on_close": false,
  #     "notify_on_close": false,
  #     "close": null,
  #     "submit": {
  #       "type": "plain_text",
  #       "text": "Submit",
  #       "emoji": true
  #     },
  #     "previous_view_id": null,
  #     "root_view_id": "VVVVVVVVVVV",
  #     "app_id": "AAAAAAAAAAA",
  #     "external_id": "",
  #     "app_installed_team_id": "TTTTTTTTT",
  #     "bot_id": "BBBBBBBBBBB"
  #   },
  #   "response_urls": []
  # }
  def create
    return render json: {err: 'invalid_team_id'}, status: :unprocessable_entity if @user.organization.slack_team_id != shortcut_params[:user][:team_id]

    type = shortcut_params[:type]
    case type
    when "view_submission"
      handle_submission
      render status: :created
    else
      handle_request
      render status: :ok
    end
  end

  private
    def get_user
      @user = User.find_by(slack_id: shortcut_params[:user][:id])
    end

    def handle_request
      slack = OmniAuth::Slack.build_access_token(ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], @user.organization.slack_bot_token)
      slack.post('api/views.open',
                 body: {trigger_id: shortcut_params[:trigger_id], view: modal_payload(@user.organization.projects)}.to_json,
                 headers: {"Content-Type": "application/json"})
    end

    def modal_payload(projects)
      project_options = projects.map do |project|
        {
            "text": {
                "type": "plain_text",
                "text": project.name
            },
            "value": "#{project.id}"
        }
      end
      {
          "type": "modal",
          "title": {
              "type": "plain_text",
              "text": "Project Subscription"
          },
          "submit": {
              "type": "plain_text",
              "text": "Submit"
          },
          "blocks": [
              {
                  "type": "section",
                  "block_id": "project_block",
                  "text": {
                      "type": "plain_text",
                      "text": "Pick an item from the dropdown list"
                  },
                  "accessory": {
                      "action_id": "select_project",
                      "type": "static_select",
                      "placeholder": {
                          "type": "plain_text",
                          "text": "which project do you subscribe?"
                      },
                      "options": project_options
                  }
              },
              {
                  "type": "input",
                  "block_id": "channel_block",
                  "element": {
                      "type": "multi_channels_select",
                      "action_id": "channels",
                      "placeholder": {
                          "type": "plain_text",
                          "text": "which channel to subscribe?"
                      }
                  },
                  "label": {
                      "type": "plain_text",
                      "text": "Channel(s)"
                  }
              }
          ]
      }
    end

    def handle_submission
      values = shortcut_submission_params[:view][:state][:values]
      project_id = values[:project_block][:select_project][:selected_option][:value]
      channels = values[:channel_block][:channels][:selected_channels]

      ActiveRecord::Base.transaction do
        channels.each do |c|
          setting = SlackJobNotification.new(
              slack_channel_id: c,
              project_id: project_id
          )
          setting.save!
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def shortcut_params
      json_params = ActionController::Parameters.new(JSON.parse(params[:payload]))
      json_params.permit(:trigger_id, :type, :user => [:id, :team_id])
    end

    def shortcut_submission_params
      ActionController::Parameters.new(JSON.parse(params[:payload]))
    end
end
