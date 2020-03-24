def logar_ms(cpf)
    find('#vUSRNUMCPFAUX').set cpf
    find('#vSENHA').set '123456'
    find('[name="BTN_LOGIN"]').click
    sleep(3)
    page.driver.browser.close
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    puts page.title
end

def candidatos()
    find('[class="ThemeClassicMainFolderText"]', :text => 'SIRH').click
    find('[class="ThemeClassicMenuFolderText"]', :text => 'Medalha Valor Militar').click
    find('[class="ThemeClassicMenuItemText"]', :text => 'Candidatos').click
    sleep(4)
    page.driver.browser.close
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    page.driver.browser.manage.window.maximize
    puts page.title
    find(:select, "TempoServicoDropDownList").first(:option, 'Maior e igual a 20 anos e menor que 30', exact: false).select_option
    click_button('btnPesquisar')
end

def selecionar_pm()
=begin
    unless page.driver.options[:options].args.include?('--headless')
        currentPage = find('table tbody tr td[colspan="8"] span').text.to_i
        tdPages = find('table tbody tr td[colspan="8"]').text.to_i
        onePage = tdPages.to_s.split('')
        expect(currentPage).to equal 1
        while onePage.include?((currentPage + 1).to_s) && currentPage <= 2
            click_link((currentPage + 1).to_s)
            sleep 2
            currentPage = find('table tbody tr td[colspan="8"] span').text.to_i
        end
    end
=end
    sleep 2
    within('#grid') do
        find('#ContentPlaceHolder1_GridView1_ConferirLinkButton_0').click
    end
    click_button('Não')
    sleep 3
    assert_selector(:id, 'tabs')
    assert_selector(:id, 'divDadosPessoais')
    assert_selector('#divMedalhaCondecoracao')
    assert_selector('#divAfastamento')
end

def dadosPessoais()
    expect(assert_selector('li[class*="ui-tabs-selected"] > a[href="#divDadosPessoais"]')).to equal true
    $re_pm = find('#ReTextBox').value
    find('input[name="ctl00$ContentPlaceHolder1$QtdElogiosTextBox"]').set ''
    find('input[name="ctl00$ContentPlaceHolder1$QtdElogiosTextBox"]').set '007'
    choose 'ContentPlaceHolder1_JuizoRadioButtonList_1'
    fill_in "ObservacoesJuizoTextBox",	with: "Preenchido em teste automatico" 
end

def justica_disciplina()
    @data = Time.new.strftime('%d%m%Y')
    $diaAfastado = Array.new
    expect(assert_selector('li[class*="ui-tabs-selected"] > a[href="#divDadosPessoais"]')).to equal true
    find('li[class="ui-state-default ui-corner-top"] > a[href="#divMedalhaCondecoracao"]').click
    adicionarSancao()
    adicionarSancao()
    all('strong#qtdDias').each do|qtdDias| 
        $diaAfastado << qtdDias.text.to_i
    end
    # define o menor nr de afastamento e pega o segundo elemento a direita via xpath (botao editar)
    find('strong#qtdDias', text: $diaAfastado.min.to_s + " dias").find(:xpath, '../following-sibling::div/following-sibling::div/button').click
    # cancelar editar
    find('#ContentPlaceHolder1_btnCancelarSancao').click
    # achar o editar e alterar o nr de boletim para Editado
    find('strong#qtdDias', text: $diaAfastado.min.to_s + " dias").find(:xpath, '../following-sibling::div/following-sibling::div/button').click
    fill_in "txtBoletinPublicacao",	with: 'Editado'
    find('#ContentPlaceHolder1_btnAdicionar').click
    # Excluir maior dia de afastamento
    find('strong#qtdDias', text: $diaAfastado.max.to_s + " dias").find(:xpath, '../following-sibling::div/following-sibling::div/following-sibling::div/button').click
    # click no Não
    find('button > span[class="ui-button-text"]', text: 'Não').click
    find('strong#qtdDias', text: $diaAfastado.max.to_s + " dias").find(:xpath, '../following-sibling::div/following-sibling::div/following-sibling::div/button').click
    sleep 7
    # click no Sim
    find('button > span[class="ui-button-text"]', text: 'Sim').click
    # Ajustar Vetor retirando o maior numero, para utilizar depois no check do numero total de afastamento
    $diaAfastado -=[$diaAfastado.max]
    sleep 3

    # Fazer download  (executar o download antes para aproveitar o pdf baixado no exemplo de re_pm.pdf)
    click_button('ButtonAbrirFormulario')
    sleep 5
    expect(File.file?"downloads/#{$re_pm}_DP.pdf").to equal true
# Renomear arquivo para adequar o exigido no salvar quando arquivo anexado: Somente o RE (retirando o "_DP")
    File.rename("downloads/#{$re_pm}_DP.pdf", "downloads/#{$re_pm}.pdf")

    # Anexar arquivo
    find('input#ContentPlaceHolder1_AdicionarDocumentoButton').click
    assert_selector('label[id="texto-dialog-advert"]', text: 'Por favor, insira um arquivo', visible: true)
    find('span[class="ui-icon ui-icon-closethick"]', text: 'close').click
    attach_file('ContentPlaceHolder1_DocumentoFileUpload', '\\\\Vmwfsrprd57\fabrica$\Testes\Anexo.pdf')
    find('input#ContentPlaceHolder1_AdicionarDocumentoButton').click
    # Excluir arquivo anexado
    find('input#ContentPlaceHolder1_DocumentoGridView_ExcluirImageButton_0').click
    page.driver.browser.switch_to.alert.accept
    # Manter o arquivo anexado para posteriormente salvar. (dessa vez com o padrão RE do PM .pdf)
    attach_file('ContentPlaceHolder1_DocumentoFileUpload', "downloads/#{$re_pm}.pdf")
    find('input#ContentPlaceHolder1_AdicionarDocumentoButton').click

    select('Sim', from: 'DadosIncompletosDropDownList')
    fill_in "ContentPlaceHolder1_DescricaoTextBox",	with: "Texto preenchido automaticamente"
    click_link 'close'
    # CLICAR EM DADOS INCOMPLETOS FARÁ USUARIO IR PARA APROVAÇÃO, NÃO UTILIZAR
=begin     select('Sim', from: 'DadosIncompletosDropDownList')
    click_button 'btnEnviar'
=end
end

def afastamento_servico()
    @diaAfastadoTabela = Hash.new
    @afastTotal = 0
    #mudar para aba Afastamento do servico
    expect(assert_selector('li[class*="ui-tabs-selected"] > a[href="#divMedalhaCondecoracao"]')).to equal true
    find('li[class="ui-state-default ui-corner-top"] > a[href="#divAfastamento"]').click
    assert_selector('table#ContentPlaceHolder1_AfastamentoGridView')
    # 
    @trsAfastamento = find('table#ContentPlaceHolder1_AfastamentoGridView > tbody').all('tr:not([style*="color:Black"]')
    @trsAfastamento.each do |diaAfastadoTabela|
        @diaAfastadoTabela[diaAfastadoTabela.find('td:nth-child(5)').text.to_i] = diaAfastadoTabela.find('td:nth-child(2)').text
    end
    find('td:nth-child(5)', text: @diaAfastadoTabela.keys.max).find(:xpath, './following-sibling::td/span/input').click
    $diaAfastado.each do |afastDia|
        puts afastDia
        @afastTotal += afastDia
    end
    # Soma os elementos do vetor criado na pagina de Justica e disciplina (atualizado apos exclusao) e compara com o valor da label do sistema 
    expect(find('#TotalAfastamentoLabel').text.to_i).to equal @afastTotal
    byebug
end

# Atualiza os textareas respectivos com algum valor para o Salvar ser concluido com sucesso
def adicionarSancao()
    find(:select, 'ContentPlaceHolder1_ddlTipoPunicao').find("option[value='#{rand(1..3)}']").select_option
    find("input#txtdataPublicacaoPunicao").set ""
    find("input#txtdataPublicacaoPunicao").set "#{@data}"
    fill_in "txtQuantDias",	with: rand(2..50)
    fill_in "txtBoletinPublicacao",	with: 'BOnr0' + rand(1..20).to_s
    fill_in "SancoesTextBox",	with: "Preenchido por automação"
    click_button 'ContentPlaceHolder1_btnAdicionar'
    expect(page).not_to have_selector('span#ContentPlaceHolder1_lblMensagem')
end

def pesquisar()
    puts page.title
    find('[class="ThemeClassicMainFolderText"]', :text => 'SIRH').click
    find('[class="ThemeClassicMenuFolderText"]', :text => 'Medalha Valor Militar').click
    find('[class="ThemeClassicMenuItemText"]', :text => 'Pesquisar').click
    sleep(4)
    page.driver.browser.close
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    page.driver.browser.manage.window.maximize
    puts page.title
    # save_screenshot
end

def ss_capture(nome_arquivo, resultado)
    caminho_arquivo = "results/screenshot/SS_#{resultado}"
    foto = "#{caminho_arquivo}/#{nome_arquivo}.png"
    page.save_screenshot(foto)
    embed(foto, 'image/png', 'Clique Aqui!')
end

class Busca < SitePrism::Page
    # set_url "http://www.casasbahia.com.br/busca?q=Iphone"
    
    element :tabela_busca, 'div .nm-search-results-container'
    element :botao_comparar, 'div[class="nm-btn-compare"]'
    elements :resultados, 'fieldset.nm-compare-product > input[id*="comparator-product-"]'
    elements :resultadoss, 'label[for*="comparator-product-"]', text: 'Comparar produtos'
    
end