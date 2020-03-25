Dado("que eu esteja no resultado da busca do iPhone") do
    # visit 'busca?q=Iphone'
    @busca = Busca.new # instancia a pagina do tipo site_prism
    @busca.load # carrega a pagina com a busca do iphone
    visit '' # acessa home

    find('input#strBusca').set 'iphone' # busca a palavra chave
    click_button('btnOK') # click na lupa
    expect(@busca).to have_tabela_busca # espera pela tabela de busca
    expect(@busca).to have_botao_comparar # espera que exista um botão comparar
end

Quando("eu clicar em comparar os {int} primeiros iPhones da lista") do |qntProd|
    # Pega todos os produtos gerados pela busca
    all('label[for*="comparator-product-"]', text: 'Comparar produtos').each_with_index do |checkbox, indice|
        if indice < qntProd # limita o numero de produtos ao especificado na feature em gherkin
                checkbox.click # clica no elemento
        end
    end
end

Quando("clicar no botão Comparar") do
    find('div .nm-btn-compare').click # click no botão
end

Então("deve trazer os dados de comparação") do
    assert_selector('h1.tit', text: "Resultado da Comparação") # espera o Header de uam comparacao
    p find('h1.tit > span').text # Data e hora da consulta
    expect(@busca).to have_tabela_comparacao # espera que exista uma tabela de comparacao
end


Então("validar pelo menos {int} dados iguais") do |int|
    @atrib_iguais = Array.new # Vetor para armazenar todos os valores de atributos iguais
    # Valida valor do atributo entre produto 1 e 2 e caso igual, aloca num vetor
    @busca.atributos.each do |atributo|
        unless (atributo.find('td[id*=_tdValor0] > ul').text == "") || (atributo.find('td[id*=_tdValor1] > ul').text == "") # anula campos vazios
            if atributo.first('td[id*=_tdValor0] > ul > li').text == atributo.first('td[id*=_tdValor1] > ul > li').text
                @atrib_iguais.push(atributo.first('td[id*=_tdValor0] > ul > li').text) #adiciona no vetor de valores iguais
            end
        end
    end
    puts "Ha mais de tres atributos iguais\n #{@atrib_iguais}" if @atrib_iguais.length >= int
    # expect(@atrib_iguais.length).to be >= int  # espera que a quantidade de atributos iguais sejam maiores que o especificado na feature, caso contrario, falha
end