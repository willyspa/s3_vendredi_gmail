


class Scrapper

  def initialize

  end

  def scrap

    villes_array = []

    page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/hauts-de-seine.html"))
    page.xpath('//a[@class="lientxt"]').each do |ville|
      villes_array << ville.text
    end

    emails = []

    page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/92/"))
    news_links = page.css("a")
    puts news_links

    news_links.each do |link|
      page_annuaire = Nokogiri::HTML(open("http://annuaire-des-mairies.com/92/#{link['href']}"))
      page_annuaire.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').each do |mail|
        emails << mail.text

      end
    end

    puts emails
    puts villes_array

    hash = Hash[villes_array.zip(emails)]
    puts hash


    CSV.open("db/email.csv", "wb") do |f|

      hash.each do |town|

        f << town

      end


    end


  end

  def readcsv

    filename = File.dirname(File.dirname(File.expand_path(__FILE__))) + '/db/email.csv'
    @maildb = []

    CSV.foreach(filename) do |row|
    @maildb << row
    end
    puts @maildb
    puts "-"*20
    puts @maildb[0][0]
    puts @maildb[0][1]
    puts @maildb[1][1]
    puts @maildb[2][1]
    @maildb = @maildb + ["test-finale","armed95@hotmail.fr"]
    puts "-"*20
    puts @maildb


  end

  def mailing



    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
    CREDENTIALS_PATH = 'credentials.json'.freeze
    # The file token.yaml stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    TOKEN_PATH = 'token.yaml'.freeze
    SCOPE = Google::Apis::GmailV1::AUTH_SCOPE

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def authorize
     client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
     token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
     authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
     user_id = 'default'
     credentials = authorizer.get_credentials(user_id)
     if credentials.nil?
       url = authorizer.get_authorization_url(base_url: OOB_URI)
       puts 'Open the following URL in the browser and enter the ' \
            "resulting code after authorization:\n" + url
       code = gets
       credentials = authorizer.get_and_store_credentials_from_code(
         user_id: user_id, code: code, base_url: OOB_URI
       )
     end
     credentials
    end

    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    for i in 0..@maildb.length-1
    # Création du contenu du message
    msg = Mail.new #msg est une instance de la classe « Mail ». On va définir ses variables d'instance
    msg.date = Time.now
    msg.subject = 'resto du coeur'
    msg.body = Text.new("Bonjour,Je m'appelle Willy et je permets de contacter la mairie de #{@maildb[i][0]} à propos du remarquable travail que font Les Restos du Coeur. Cette association répand le bien dans la France et aide les plus démunis à s'en tirer. Avez-vous pensé à travailler avec eux ? Soutenir Les Restos du Coeur, c'est important pour notre cohésion sociale : rejoignez le mouvement !Merci à vous", 'plain', 'charset' => 'us-ascii')
    msg.from = {'willyspa1987@gmail.com' => 'willy'}
    msg.to   = {
       @maildb[i][1] => nil,
    }

    # Création de la requête, insertion du contenu dans la propriété `raw`
    #(https://developers.google.com/gmail/api/v1/reference/users/messages/send)
    message = Google::Apis::GmailV1::Message.new(raw: msg.to_s)

    service.send_user_message('me', message)

    end

  end



end
