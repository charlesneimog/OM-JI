# OM-JI
This Library desires to create an environment for the microtonal music composition, mainly for Just Intonation composition. This library constructs the theory of Harry Partch, Erv Wilson, and Ben Johnston. 


*It is compatible with OpenMusic and OM#*. 

See http://charlesneimog.com/ 

See: https://github.com/cac-t-u-s/om-sharp and https://github.com/openmusic-project/
 
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

**Choose**: Este objeto é responsável por fazer a escolha de um elemento dentro de uma lista. No inlet1 temos uma lista de notas ou uma lista de listas. E no inlet2 o número da lista ou número que queremos. É possível selecionar duas estruturas colocando mais números no inlet2. 

**Range-reduce**: Este objeto é responsável por reduzir os dados em midicents a uma certa extensão. No intlet1 colocamos a lista de notas que será reduzida. No inlet2 a nota mais grave da redução e no inlet3 a nota mais aguda. Caso a diferença entre esses inlets for menor que 1200¢ a avaliação dará erro e apresentará a seguinte mensagem: “RANGE-REDUCE: The diference between the inlet2 e inlet3 must be at least 1200 cents.” De forma a orientar o uso de tal biblioteca pois caso haja menos de 1200¢ o objeto entraria em um loop eterno.


![Range Reduce](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Range%20Reduce.png)

**Modulation-notes**: Este objeto foi pensado a partir da leitura da tese de doutorado de Daniel James Huey (2017) que se intitula Harmony, Voice Leading, and Microtonal Syntax in Ben Johnston’ s String Quartet No. 5. Nesta tese, o autor afirmará que notas em comum dentro de áreas de afinação são de importantes para a concepção e modulação entre essas áreas. Na peça Arabesque | 19 11 97 há a intenção de fazer a modulação de uma Tonalidade Diamante construída sobre os números (16 27 35 38 49 54 60) para a estrutura de Ben Johnston construída sobre o C# tendo como base o intervalo 97/64. Para fazer essa modulação, após testar sem sucesso várias formas, encontramos nas duas estruturas uma nota em comum, o C# -6¢. Este ato de encontrar notas em comum é que se implementa neste objeto. 

![Modulation Notes](https://github.com/charlesneimog/OM-JI/blob/master/resources/Imagens/Modulations%20notes.png)

**Modulation-notes-fund**: Este objeto mostrará as notas que serão iguais caso haja mudança das notas de referência da segunda estrutura de afinação (inlet 2). Os inlet’s 1, 2 e 3 seguem as mesmas instruções que os inlet’s do objeto modulation-notes. No inlet 4 devemos dizer se o objeto levará em conta possíveis fundamentais nas notas temperadas em semitom (2), quarto de tom (4), oitavo de tom (8), etc. Com este objeto, temos auxilio ao decidir uma fundamental nos baseando em alturas que serão iguais em estruturas diferentes. Por exemplo, se obra Arabesque | 19 11 97 tivesse sido composta após a implementação deste objeto, veríamos, por exemplo, que a estrutura de Ben Johnston teria mais notas em comum com a estrutura de Partch caso sua fundamental fosse em E, C#-50¢, C#+50¢ ou E+50¢ e não em C#. Pois com essas fundamentais teríamos 3 notas em comum com a estrutura de Partch enquanto que em C# temos somente uma nota em comum. Abaixo demonstramos o patch que visa comparar estruturas e mostrar quantas vezes uma mesma alteração aparece.
