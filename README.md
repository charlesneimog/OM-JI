# OM-JI
This Library desires to create an environment for the microtonal music composition, mainly for Just Intonation composition. This library constructs the theory of Harry Partch, Erv Wilson, and Ben Johnston. 

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Licença Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/80x15.png" /></a><br />Esta obra está licenciada com uma Licença <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Atribuição-NãoComercial 4.0 Internacional</a>.

**It is compatible with OpenMusic and OM#**. 

See http://charlesneimog.com/ 
 
**Biblioteca desenvolvida no Programa de Pós Graduação em Artes, Culturas e Linguagens com apoio da Univerdade Federal de Juiz de Fora (UFJF).**

**Choose**: Este objeto é responsável por fazer a escolha de um elemento dentro de uma lista. No inlet1 temos uma lista de notas ou uma lista de listas. E no inlet2 o número da lista ou número que queremos. É possível selecionar duas estruturas colocando mais números no inlet2. 

![Choose](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/choose.png)

**Range-reduce**: Este objeto é responsável por reduzir os dados em midicents a uma certa extensão. No intlet1 colocamos a lista de notas que será reduzida. No inlet2 a nota mais grave da redução e no inlet3 a nota mais aguda. Caso a diferença entre esses inlets for menor que 1200¢ a avaliação dará erro e apresentará a seguinte mensagem: “RANGE-REDUCE: The diference between the inlet2 e inlet3 must be at least 1200 cents.” De forma a orientar o uso de tal biblioteca pois caso haja menos de 1200¢ o objeto entraria em um loop eterno.

![Range Reduce](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Range%20Reduce.png)

**Modulation-notes**: Este objeto foi pensado a partir da leitura da tese de doutorado de Daniel James Huey (2017) que se intitula Harmony, Voice Leading, and Microtonal Syntax in Ben Johnston’ s String Quartet No. 5. Nesta tese, o autor afirmará que notas em comum dentro de áreas de afinação são de importantes para a concepção e modulação entre essas áreas. Na peça Arabesque | 19 11 97 há a intenção de fazer a modulação de uma Tonalidade Diamante construída sobre os números (16 27 35 38 49 54 60) para a estrutura de Ben Johnston construída sobre o C# tendo como base o intervalo 97/64. Para fazer essa modulação, após testar sem sucesso várias formas, encontramos nas duas estruturas uma nota em comum, o C# -6¢. Este ato de encontrar notas em comum é que se implementa neste objeto. 

![Modulation Notes](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Modulations%20notes.png)



# Algumas aplicações com a OM-Sieves

Criar estruturas de alturas simétricas para a construção de timbres. 

![Conteúdo Espectral Simétrico](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Conte%C3%BAdo%20espectral%20simetrica%20.png).

O conteúdo intervalar deste timbre é palíndromo. Temos os seguintes intervalos:(924¢ 231¢ 462¢ 694¢ 231¢ 694¢ 231¢ 694¢ 462¢ 231¢ 924¢).

Exemplos sonoros de processamento com o timbre acima mencionado. https://bit.ly/3p8MOJZ


![Patch em OM#](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Change%20the%20partials%20of%20the%20timbre.png).

![Ressíntese no MAX/MSP](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Exemplo%20no%20Max-MSP.png).
