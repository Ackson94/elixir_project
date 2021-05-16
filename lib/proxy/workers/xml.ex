defmodule Proxy.Workers.Xml do
  import SweetXml

  #----------- PARSE REQUEST ------------
  def parse_soap(xmlDoc) do
    xmlDoc
    |>xpath(
      ~x"//soap:Envelope/soap:Body/ns2:fundTransferMobileToAccount",
      bank_name: ~x"./txtBankName/text()",
      branch_code: ~x"./txtBranchCode/text()",
      accountNumber: ~x"./txtAccountNumber/text()",
      senderMobileNumber: ~x"./txtAuthNum/text()",
      benef_fname: ~x"./txtBFName/text()",
      benef_lname: ~x"./txtBLName/text()",
      amount: ~x"./txtAmount/text()",
      currency: ~x"./txtCurrency/text()",
      externalId: ~x"./txtRefID/text()",
      transmissionDateTime: ~x"./mydate/text()",
      username: ~x"./txtExternal1/text()",
      password: ~x"./txtExternal2/text()"
      )
  end

  #------------ CREATE RESPONSE ------------------------
  def create_response(request, response, "SUCCESS") do
    ~s(<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://deploy.fasyl.xnett.com/">
        <SOAP-ENV:Body>
          <ns1:fundTransferMobileToAccountResponse>
            <return>
              <balance>#{String.trim("#{response["balance"]}")}</balance>
              <status>200</status>
              <transactionAmount>#{String.trim("#{request.amount}")}</transactionAmount>
              <transactionDetails>success</transactionDetails>
              <transactionID>#{String.trim("#{request.externalId}")}</transactionID>
              <transactionTimeStamp>#{String.trim("#{request.transmissionDateTime}")}</transactionTimeStamp>
            </return>
          </ns1:fundTransferMobileToAccountResponse>
        </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>)
  end

  def create_response(request, response, "FAIL") do
    IO.inspect response
    ~s(<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://deploy.fasyl.xnett.com/">
        <SOAP-ENV:Body>
          <ns1:fundTransferMobileToAccountResponse>
            <return>
              <balance>0</balance>
              <status>300</status>
              <transactionAmount>#{String.trim("#{request.amount}")}</transactionAmount>
              <transactionDetails>#{String.trim("#{response["errorMessage"]}")}</transactionDetails>
              <transactionID>#{String.trim("#{request.externalId}")}</transactionID>
              <transactionTimeStamp>#{String.trim("#{request.transmissionDateTime}")}</transactionTimeStamp>
            </return>
          </ns1:fundTransferMobileToAccountResponse>
        </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>)
  end

  def parse_enquiry(xmlDoc) do
    xmlDoc
    |>xpath(
      ~x"//COMMAND",
      txn_type: ~x"./TYPE/text()",
      interface_id: ~x"./INTERFACEID/text()",
      externalId: ~x"./EXTTRID/text()"
      )
  end

  def confirm(request, transaction) do
    status_code = if(transaction.status_code == "200", do: "200", else: "300")
    ~s(<COMMAND>
        <TYPE>TXNEQRESP</TYPE>
        <TXNID>#{String.trim("#{request.externalId}")}</TXNID>
        <EXTTRID>#{String.trim("#{request.externalId}")}</EXTTRID>
        <TXNSTATUS>#{String.trim("#{status_code}")}</TXNSTATUS>
        <MESSAGE>#{String.trim("#{transaction.status_descript}")}</MESSAGE>
       </COMMAND>)
  end
end
