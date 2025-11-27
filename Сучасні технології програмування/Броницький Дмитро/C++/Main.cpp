#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <cctype>
#include <map>
#include <iomanip>

using namespace std;

string to_upper_copy(const string& s) {
    string r = s;
    for (char& c : r) c = toupper(c);
    return r;
}

string normalize_key(const string& key) {
    string r;
    for (char c : key)
        if (isalpha(static_cast<unsigned char>(c)))
            r.push_back(toupper(c));
    return r;
}

char shift_enc(char p, char k) {
    return char('A' + ((p - 'A') + (k - 'A')) % 26);
}

char shift_dec(char c, char k) {
    return char('A' + ((c - 'A') - (k - 'A') + 26) % 26);
}

string encrypt(const string& text, const string& key_raw) {
    string key = normalize_key(key_raw);
    string res = text;
    int j = 0;
    for (int i = 0; i < text.size(); i++) {
        char c = text[i];
        if (isalpha((unsigned char)c)) {
            bool low = islower((unsigned char)c);
            char u = toupper(c);
            char e = shift_enc(u, key[j % key.size()]);
            if (low) e = tolower(e);
            res[i] = e;
            j++;
        }
    }
    return res;
}

string decrypt(const string& text, const string& key_raw) {
    string key = normalize_key(key_raw);
    string res = text;
    int j = 0;
    for (int i = 0; i < text.size(); i++) {
        char c = text[i];
        if (isalpha((unsigned char)c)) {
            bool low = islower((unsigned char)c);
            char u = toupper(c);
            char d = shift_dec(u, key[j % key.size()]);
            if (low) d = tolower(d);
            res[i] = d;
            j++;
        }
    }
    return res;
}

void freq(const string& text) {
    vector<int> cnt(26, 0);
    int tot = 0;
    for (char c : text) {
        if (isalpha((unsigned char)c)) {
            cnt[toupper(c) - 'A']++;
            tot++;
        }
    }
    cout << "\n=== Frequency analysis ===\n";
    for (int i = 0; i < 26; i++) {
        if (cnt[i] > 0) {
            double p = 100.0 * cnt[i] / tot;
            cout << char('A' + i) << ": " << cnt[i] 
                 << " (" << fixed << setprecision(2) << p << "%)\n";
        }
    }
}

int main() {
    string key = "LEMON";
    string text = "Attack at dawn!";

    cout << "Key:   " << key << "\n";
    cout << "Plain: " << text << "\n";

    string cipher = encrypt(text, key);
    cout << "Encrypted: " << cipher << "\n";

    string plain = decrypt(cipher, key);
    cout << "Decrypted: " << plain << "\n";

    freq(cipher);

    return 0;
}
