Dado("que eu esteja no resultado da busca do iPhone") do
# visit 'busca?q=Iphone'
@busca = Busca.new
# @busca.load
visit ''

find('input#strBusca').set 'iphone'
click_button('btnOK')
byebug
expect(@busca).to have_tabela_busca
expect(@busca).to have_botao_comparar
end

Quando("eu clicar em comparar os {int} primeiros iPhones da lista") do |qntProd|
 all('label[for*="comparator-product-"]', text: 'Comparar produtos').each_with_index do |checkbox, indice|
        if indice < qntProd
            checkbox.click
        end
    end

    # @busca.resultadoss[0].click
    # @busca.resultadoss[1].click
    byebug
end

Quando("clicar no botão Comparar") do
    find('div .nm-btn-compare').click
    
end

Então("deve trazer os dados de comparação") do
end

Então("validar pelo menos {int} dados iguais") do |int|

end