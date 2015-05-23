#include <list>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>


class Row
{
public:

    void add_id(int id)
    {
        if (ids.empty() || ids.back() < id)
        {
            ids.push_back(id);
        }
        else if (ids.back() > id)
        {
            auto it = ids.begin();

            while (*it < id)
            {   ++it; }

            if (*it != id)
            {   ids.insert(it, id); }
        }
    }


    SV* listref()
    {
        AV* arr = newAV();
        for (int i : ids)
        {
            av_push(arr, newSViv(i));
        }
        return newRV_noinc(reinterpret_cast<SV*>(arr));
    }


    void and_with(const Row* rhs)
    {
        auto lit =      ids.begin();
        auto rit = rhs->ids.begin();

        while (lit != ids.end() && rit != rhs->ids.end())
        {
            if (*lit < *rit)
            {
                lit = ids.erase(lit);
            }
            else if (*lit > *rit)
            {
                ++rit;
            }
            else
            {
                ++lit;
                ++rit;
            }
        }

        ids.erase(lit, ids.end());
    }


    void or_with(const Row* rhs)
    {
        auto lit =      ids.begin();
        auto rit = rhs->ids.begin();

        while (lit != ids.end() && rit != rhs->ids.end())
        {
            if (*lit < *rit)
            {
                ++lit;
            }
            else if (*lit > *rit)
            {
                ids.insert(lit, *rit);
                ++rit;
            }
            else
            {
                ++lit;
                ++rit;
            }
        }

        ids.insert(lit, rit, rhs->ids.end());
    }


    void but_with(const Row* rhs)
    {
        auto lit =      ids.begin();
        auto rit = rhs->ids.begin();

        while (lit != ids.end() && rit != rhs->ids.end())
        {
            if (*lit < *rit)
            {
                ++lit;
            }
            else if (*lit > *rit)
            {
                ++rit;
            }
            else
            {
                lit = ids.erase(lit);
                ++rit;
            }
        }
    }


private:
    std::list<int> ids;

};


class InvertedIndex
{
public:

    void add_document(const char* original, const char* folded)
    {
        auto id = documents.size();
        documents.push_back(original);

        std::stringstream ss(folded);
        std::string token;
        while (std::getline(ss, token, ' '))
        {
            indices[token].add_id(id);
        }
    }


    void fetch(const char* token, Row* out) const
    {
        auto it = indices.find(token);
        if (it != indices.end())
        {   *out = it->second; }
    }


    const char* get_document(int id) const
    {
        return id >= 0 && id < documents.size()
             ? documents[id].c_str()
             : NULL;
    }


private:

    std::vector<std::string> documents;
    std::unordered_map<std::string, Row> indices;

};
