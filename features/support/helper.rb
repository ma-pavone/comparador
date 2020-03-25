def ss_capture(nome_arquivo, resultado)
    caminho_arquivo = "results/screenshot/SS_#{resultado}"
    foto = "#{caminho_arquivo}/#{nome_arquivo}.png"
    page.save_screenshot(foto)
    embed(foto, 'image/png', 'Clique Aqui!')
end

class Busca < SitePrism::Page
    set_url "http://www.casasbahia.com.br/busca?q=Iphone"
    
    element :tabela_busca, 'div.nm-search-results-container'
    element :botao_comparar, 'div[class="nm-btn-compare"]'
    elements :resultados, 'label[for*="comparator-product-"]', text: 'Comparar produtos'
    element :tabela_comparacao, 'div .corpoComparacao'
    elements :atributos, 'tr.atributos'
end
