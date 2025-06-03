from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/cep/<cep>', methods=['GET'])
def consultar_cep(cep):
    url = f"https://viacep.com.br/ws/{cep}/json/"
    response = requests.get(url)
    if response.status_code == 200:
        dados = response.json()
        if "erro" not in dados:
            return jsonify(dados)
        else:
            return jsonify({"erro": "CEP n?o encontrado."}), 404
    else:
        return jsonify({"erro": "Erro na consulta."}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
