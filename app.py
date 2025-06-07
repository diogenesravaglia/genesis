from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/cep/<cep>', methods=['GET'])
def consultar_cep(cep):
    """Consult the ViaCEP service and return information about a CEP."""

    # Basic validation for the CEP format. ViaCEP expects exactly 8 digits.
    if not cep.isdigit() or len(cep) != 8:
        return jsonify({"erro": "Formato de CEP inválido."}), 400

    url = f"https://viacep.com.br/ws/{cep}/json/"
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
    except requests.exceptions.RequestException:
        # Any connection error should return a generic server error
        return jsonify({"erro": "Erro na consulta."}), 500

    dados = response.json()
    if "erro" in dados:
        return jsonify({"erro": "CEP não encontrado."}), 404

    return jsonify(dados)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
