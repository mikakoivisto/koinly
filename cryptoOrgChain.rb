require 'date'
require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'bigdecimal'

basecro = BigDecimal.new("100000000")
limit = 100000

account = ARGV[0]

unless account
  puts "Usage: ./cryptoOrgChain.rb [account address]"
  exit 1
end  

json = JSON(Net::HTTP.get(URI("https://crypto.org/explorer/api/v1/accounts/#{account}/transactions?limit=#{limit}&order=height.desc")))
result = json["result"]
pagination = json["pagination"]
 
headers = ["Date",	"Sent Amount",	"Sent Currency",	"Received Amount",	"Received Currency",	"Fee Amount", "Fee Currency", "Net Worth Amount",	"Net Worth Currency", "Label", "Description",	"TxHash"]
CSV.open("cryptoorg-chain-#{account}-koinly.csv", 'wb') { 
    |csv| 
    csv << headers
    loop do 
      result.each do |tx|
        next unless tx["success"]
        msgType = tx["messages"][0]["type"]
        next if msgType == "MsgBeginRedelegate"
        txdate = DateTime.parse(tx["blockTime"]).strftime("%Y-%m-%d %H:%M:%S") # YYYY-MM-DD HH:mm:ss
        txhash = tx["hash"]
        fee = (BigDecimal.new(tx["fee"][0]["amount"]) / basecro).to_s("F")
        amountElem = tx["messages"][0]["content"]["amount"]
        if (amountElem.class == Array)
          amount = (BigDecimal.new(amountElem[0]["amount"])/basecro).to_s("F")
        else
          amount = (BigDecimal.new(amountElem["amount"])/basecro).to_s("F")
        end
        toAddress = tx["messages"][0]["content"]["toAddress"]
        fromAddress = tx["messages"][0]["content"]["fromAddress"]
        validatorAddress = tx["messages"][0]["content"]["validatorAddress"]
        sentAmount = ""
        sentCurrency = ""
        receivedAmount = ""
        receivedCurrency = ""
        feeAmount = ""
        feeCurrency = ""
        label = ""
        description = ""

        if (toAddress == account && msgType == "MsgSend")
          receivedAmount = amount
          receivedCurrency = "CRO"
          description = "Received from #{fromAddress}"
        elsif (toAddress != account && msgType == "MsgSend")
          sentAmount = amount
          sentCurrency = "CRO"
          feeAmount = fee
          feeCurrency = "CRO"
          description = "Sent to #{toAddress}"
        elsif (msgType == "MsgWithdrawDelegatorReward")
          receivedAmount = amount
          receivedCurrency = "CRO"
          label = "staking"
          description = "Staking reward from validator #{validatorAddress}"
        elsif (msgType == "MsgDelegate")
          sentAmount = amount
          sentCurrency = "CRO"
          feeAmount = fee
          feeCurrency = "CRO"
          description = "Delegating to validator #{validatorAddress}"
        end
        row = [txdate, sentAmount, sentCurrency, receivedAmount, receivedCurrency, feeAmount, feeCurrency, "", "", label, description, txhash]  
        csv << row
      end

      if pagination["current_page"] != pagination["total_page"]
        page = pagination["current_page"] + 1
        puts "Fetching page #{page}"
        json = JSON(Net::HTTP.get(URI("https://crypto.org/explorer/api/v1/accounts/#{account}/transactions?pagination=offset&page=#{page}&limit=#{limit}&order=height.desc")))
        result = json["result"]
        pagination = json["pagination"]
      else
        break
      end
    end
}